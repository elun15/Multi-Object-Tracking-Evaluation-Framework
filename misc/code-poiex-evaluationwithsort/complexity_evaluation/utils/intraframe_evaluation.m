function result=intraframe_evaluation(datasetDir,detectDir,outputDir,seqmap,config)
%% This script computes the intraframe evaluation
%
%
% OUTPUT: For each "ss" sequence, an struct with the following fields:
%   result{ss} = struct('seqDir',seqDir,'gtFile',gtFile,'deFile',deFile,'etFile',etFile,...
%        'gtInfo',gtInfo,'deInfo',deInfo,'esInfo',esInfo,...
%        'assoc_gt_de',assoc_gt_de,'cost_gt_de',cost_gt_de,'overlap_gt_de',overlap_gt_de,...
%        'assoc_gt_tr',assoc_gt_tr,'cost_gt_tr',cost_gt_tr,'overlap_gt_tr',overlap_gt_tr,...
%        'TPdet',TPdet,'FPdet',FPdet,'FNdet',FNdet,'Ndet',Ndet,...
%        'TPest',TPest,'FPest',FPest,'FNtrt',FNtrt,'Ntrt',Ntrt,...
%        'Ngt',Ngt1,'trackMetrics',trackMetrics,'intraScore',intraScore); 
%
%        Additionally, comparison figures are also saved
% 
% NOTE: 
%   - Format for Ground-truth & detection files:
%              <frame> <ID> <top-left X> <top-left Y> <width> <height> <confidence>
%
%   - Format returned by "convertTXTToStruct":
%       <X> centerX?
%       <Y> centerY?
%       <Xi> <top-left X> + <width>/2 (feet location?)  
%       <Yi> <top-left Y> + <height> (feet location?)
%       <W> width of the bounding box
%       <H> height of the bounding box
%
% Author: Juan Carlos
% Original date: 29/12/2016 (Last edit: 10/01/2017)
% addpath ('../../devkit/utils');

%% SETTINGS
if (nargin == 3)
    %read all ground-truth data
    Seqs = dir(datasetDir);
    Seqs = strsplit(sprintf('%s ',Seqs(3:end).name)); %remove '.' & '..'
    Seqs = Seqs(1:end-1); %remove empty '' at the end
else
    Seqs = textread(seqmap, '%s', 'delimiter', '\n');
    Seqs = Seqs(2:end); %remove firt element  'name'
end

DISPLAY_FRAME = config.DISPLAY_FRAME;
DISPLAY_SEQ = config.DISPLAY_SEQ;

% SEQUENCE PROCESSING
for ss=1:numel(Seqs)    
    
    % path to data
    seqDir = fullfile(datasetDir,Seqs{ss},filesep);
    gtFile = fullfile(datasetDir,Seqs{ss},'gt','gt.txt');   %ground-truth
    %deFile = fullfile(datasetDir,Seqs{ss},'det','det.txt'); %detections    
    deFile = fullfile(detectDir,[Seqs{ss} '.txt']);        %estimated tracks
    etFile = fullfile(outputDir,[Seqs{ss} '.txt']);        %estimated tracks
    
    fprintf('\nRETRIEVING DATA FOR %s\n',Seqs{ss});
    % get data
    gtInfo = convertTXTToStruct(gtFile,seqDir);
    fprintf('Importing data from %s\n',deFile);
    deInfo = csvread(deFile);
    esInfo = convertTXTToStruct(etFile,seqDir);
    
    % find positions with valid data
    gtInd=~~gtInfo.X;
    esInd=~~esInfo.X;
    
    % get the number of frames and targets
    [Nframes_GT(ss), Ntarget_GT(ss)]=size(gtInfo.X);
    [Nframes(ss), Ntarget(ss)]=size(esInfo.X);
    
    %initialize variables
    assoc_gt_tr = []; %association matrix between gtruth & trajectories (tracker estimation)
    assoc_gt_de = []; %association matrix between gtruth & detections
    
    cost_gt_tr  = []; %association cost between gtruth & trajectories (tracker estimation)
    cost_gt_de  = []; %association cost between gtruth & detections
    
    costM_gt_tr = []; %matrix cost between gtruth & trajectories (tracker estimation)
    costM_gt_de = []; %matrix cost between gtruth & detections
    
    overlap_gt_tr = cell(1,Nframes(ss)); %spatial overlap between gtruth & trajectories (tracker estimation)
    overlap_gt_de = cell(1,Nframes(ss)); %spatial overlap between gtruth & detections
    
    Nassoc_gt_de = [];
    Nassoc_gt_tr = [];
    
    N_non_assoc_gt_de = [];
    N_non_assoc_gt_tr = [];
    
    card_gt_de = []; % cardinality factor of METE
    card_gt_tr = []; % cardinality factor of METE
    
    mete_gt_tr = []; % multi extended-target tracking error (mete) between gtruth & trajectories (tracker estimation)
    mete_gt_de = []; % multi extended-target tracking error (mete) between gtruth & detection
    
    mete_de = [];
    mete_tr = [];
    IntraComplexity = [];
    
    % process each sequence    
    for kk = 1:Nframes(ss)
        
        % find elements for each frame
        idx_gt=find(gtInd(kk,:));
        idx_tr=find(esInd(kk,:));
        idx_de=find(deInfo(:,1)==kk);
        
        %initialize variables for processed data
        overlap_gt_tr{kk} = zeros(numel(idx_gt),numel(idx_tr)); %overlap between gtruth & tracker estimation
        overlap_gt_de{kk} = zeros(numel(idx_gt),numel(idx_de)); %overlap between gtruth & detections
        
        % compute the spatial overlap
        for gt=1:numel(idx_gt) %for each ground-truth detection
            %get the bounding box
            ind = idx_gt(gt);
            GT=[gtInfo.X(kk,ind)-gtInfo.W(kk,ind)/2 ...
                gtInfo.Y(kk,ind)-gtInfo.H(kk,ind) ...
                gtInfo.W(kk,ind) gtInfo.H(kk,ind) ];
            
            for es=1:numel(idx_tr) %for each tracker estimation (state)
                %get the bounding box
                ind = idx_tr(es);
                ST=[esInfo.Xi(kk,ind)-esInfo.W(kk,ind)/2 ...
                    esInfo.Yi(kk,ind)-esInfo.H(kk,ind) ...
                    esInfo.W(kk,ind) esInfo.H(kk,ind) ];
                
                %compute the overlap against ground-truth
                overlap_gt_tr{kk}(gt,es)=boxiou(GT(1),GT(2),GT(3),GT(4),ST(1),ST(2),ST(3),ST(4));
            end
            
            for de=1:numel(idx_de) %for each detection (state)
                %get the bounding box
                ind = idx_de(de);
                DE = deInfo(ind,3:6);
                
                %compute the overlap against ground-truth
                overlap_gt_de{kk}(gt,de)=boxiou(GT(1),GT(2),GT(3),GT(4),DE(1),DE(2),DE(3),DE(4));
            end
        end
        
        % perform data association using Hungarian
        %compute cost matrices
        costM_gt_de{kk} = 1 - overlap_gt_de{kk};  
        costM_gt_de{kk}(costM_gt_de{kk}==1) = Inf; %Infinite cost when for "no overlap" case
        
        costM_gt_tr{kk} = 1 - overlap_gt_tr{kk};
        costM_gt_tr{kk}(costM_gt_tr{kk}==1) = Inf; %Infinite cost when for "no overlap" case
        
        %do the association and get the overall cost
        [assoc_gt_de{kk}, cost_gt_de(kk)] = Hungarian(costM_gt_de{kk});
        [assoc_gt_tr{kk}, cost_gt_tr(kk)] = Hungarian(costM_gt_tr{kk});
        
        % number of associations
        Nassoc_gt_de(kk) = sum(assoc_gt_de{kk}(:)); %number of associations for detections
        Nassoc_gt_tr(kk) = sum(assoc_gt_tr{kk}(:)); %number of associations for trajectories
        
        % cost of associations
        Cost_assoc_gt_de(kk) = cost_gt_de(kk)/(sum(assoc_gt_de{kk}(:)) + eps);
        Cost_assoc_gt_tr(kk) = cost_gt_tr(kk)/(sum(assoc_gt_tr{kk}(:)) + eps);
        
        % cost of number of non-associations
        Cost_non_assoc_gt_de(kk) = abs(min(size(overlap_gt_de{kk},1), size(overlap_gt_de{kk},2)) - sum(assoc_gt_de{kk}(:))) / (min(size(overlap_gt_de{kk},1), size(overlap_gt_de{kk},2)) + eps);
        Cost_non_assoc_gt_tr(kk) = abs(min(size(overlap_gt_tr{kk},1), size(overlap_gt_tr{kk},2)) - sum(assoc_gt_tr{kk}(:))) / (min(size(overlap_gt_tr{kk},1), size(overlap_gt_tr{kk},2)) + eps);

        % cardinality cost (from METE)
        card_gt_de(kk) = abs(size(overlap_gt_de{kk},1) - size(overlap_gt_de{kk},2)) / max([size(overlap_gt_de{kk},1), size(overlap_gt_de{kk},2)]);
        card_gt_tr(kk) = abs(size(overlap_gt_tr{kk},1) - size(overlap_gt_tr{kk},2)) / max([size(overlap_gt_tr{kk},1), size(overlap_gt_tr{kk},2)]);
        
        % note that I removed the definition of METE to avoid confusion
        % because it is not calculated in the same as the original one
        
        % E
        E_gt_de(kk) = 0.5 * (Cost_assoc_gt_de(kk) + Cost_non_assoc_gt_de(kk)) + card_gt_de(kk);
        E_gt_tr(kk) = 0.5 * (Cost_assoc_gt_tr(kk) + Cost_non_assoc_gt_tr(kk)) + card_gt_tr(kk);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This part is dedicated to the calculation of intra-frame
        % complexity using METE
        
        [~, cost_de] = Hungarian(1 - overlap_gt_de{kk});
        [~, cost_tr] = Hungarian(1 - overlap_gt_tr{kk});
        
        mete_de(kk) = (cost_de + abs(size(overlap_gt_de{kk},1) - size(overlap_gt_de{kk},2))) / max([size(overlap_gt_de{kk},1), size(overlap_gt_de{kk},2)]);
        mete_tr(kk) = (cost_tr + abs(size(overlap_gt_tr{kk},1) - size(overlap_gt_tr{kk},2))) / max([size(overlap_gt_tr{kk},1), size(overlap_gt_tr{kk},2)]);
        
        if E_gt_de(kk) >= E_gt_tr(kk)
            IntraComplexity(kk) = mete_de(kk)^config.GAMMA - mete_tr(kk)^config.GAMMA;
        else
            IntraComplexity(kk) = -((1-mete_de(kk))^config.GAMMA - (1-mete_tr(kk))^config.GAMMA);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % display results
        if (any(DISPLAY_FRAME>=kk) && any(DISPLAY_SEQ>=ss))
            filename = fullfile(seqDir,'img1',sprintf('%06d.jpg',kk));
            display_frame_data (filename, ss, kk, idx_gt, idx_tr, idx_de, gtInfo, deInfo, esInfo,...
                overlap_gt_de, overlap_gt_tr, assoc_gt_de{kk}, assoc_gt_tr{kk}, cost_gt_de(kk), cost_gt_tr(kk), 1);
        end
    end
    
    %% MOT metrics
    %compute frame-level performance    
    [TPde, FPde, FNde, Nde, Ngt_de] = PerformanceAssociationFrameLevel(assoc_gt_de,overlap_gt_de);    
    printFrameLevelMetrics('Frame-level performance for detections:',[sum(TPde)/sum(Ngt_de) sum(TPde)/sum(Nde) sum(Ngt_de) sum(Nde) sum(TPde) sum(FPde) sum(FNde)]);
    
    [TPtr, FPtr, FNtr, Ntr, Ngt_tr] = PerformanceAssociationFrameLevel(assoc_gt_tr,overlap_gt_tr);    
    printFrameLevelMetrics('Frame-level performance for trajectories:',[sum(TPtr)/sum(Ngt_tr) sum(TPtr)/sum(Ntr) sum(Ngt_tr) sum(Ntr) sum(TPtr) sum(FPtr) sum(FNtr)]);
    
    %compute tracking performance
    [trackMetrics, ~, ~] = CLEAR_MOT_HUN(gtInfo,esInfo);
    disp('Multi-target tracking performance:');
    printMetrics(trackMetrics);
 
    normalize_fun =@(E_d,E_t) (E_d-E_t) ./ E_d;    
    intraScore_A = normalize_fun(cost_gt_de./Ngt_de,cost_gt_tr./Ngt_de);
    intraScore_C = normalize_fun(card_gt_de,card_gt_tr);
    intraScore = intraScore_A + intraScore_C; 

     %save processed data in cell "results"
      result{ss} = struct('seq',Seqs{ss},'seqDir',seqDir,'gtFile',gtFile,'deFile',deFile,'etFile',etFile,...
        'gtInfo',gtInfo,'deInfo',deInfo,'esInfo',esInfo,...
        'Nframes_GT', Nframes_GT(ss),'Nframes',Nframes(ss),...        
        'cost_gt_de',{cost_gt_de},'costM_gt_de',{costM_gt_de},'overlap_gt_de',{overlap_gt_de},...
        'cost_gt_tr',{cost_gt_tr},'costM_gt_tr',{costM_gt_tr},'overlap_gt_tr',{overlap_gt_tr},...
        'assoc_gt_de',{assoc_gt_de},'assoc_gt_tr',{assoc_gt_tr},'Nassoc_gt_de',Nassoc_gt_de,'Nassoc_gt_tr',Nassoc_gt_tr,...
        'Cost_assoc_gt_de', Cost_assoc_gt_de, 'Cost_assoc_gt_tr', Cost_assoc_gt_tr,...
        'Cost_non_assoc_gt_de', Cost_non_assoc_gt_de, 'Cost_non_assoc_gt_tr', Cost_non_assoc_gt_tr,...
        'card_gt_de',card_gt_de,'E_gt_de', E_gt_de,...
        'card_gt_tr',card_gt_tr,'E_gt_tr', E_gt_tr,...
        'TPde',TPde,'FPde',FPde,'FNde',FNde,'Nde',Nde,...
        'TPtr',TPtr,'FPtr',FPtr,'FNtr',FNtr,'Ntr',Ntr,...
        'Ngt',Ngt_de,'Ngt_de',Ngt_de,'Ngt_tr',Ngt_tr,...
        'trackMetrics',trackMetrics,...
        'intraScore',intraScore,'intraScore_A',intraScore_A,'intraScore_C',intraScore_C,...
        'mete_de', mete_de, 'mete_tr', mete_tr, 'IntraComplexity', IntraComplexity);
end

%% PLOT RESULTS
% display sequence results
display_sequence_data(result,config);

% display overall results
display_overall_data(result,Seqs,config);