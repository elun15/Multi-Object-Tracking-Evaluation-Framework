function [] = generate_detections(a)

%PATH and PARAMETERS

baseFolder = pwd;
detections_path = [baseFolder '/Results/Detections/'];
datasets_path = [baseFolder '/Datasets/'];

[datasets_names, datasets_paths] = get_folders(datasets_path);



%% LOAD DATA
%addpath(genpath('utils'));
gt_data= {};
det_data= [];
sequences_names={};
for i = 1:numel(datasets_names) %i = dataset
    
    sequences_names_raw=dir([datasets_path datasets_names{i}]);
    
    % Remove '.'and '..' hidden directories
    
    for k=1:length(sequences_names_raw)
        foldername = sequences_names_raw(k).name;
        if ( (strcmp(foldername, '.' ) == 0) && (strcmp(foldername, '..' ) == 0))
            sequences_names{end+1} = foldername;
        end
    end
    
    for j = 1:numel(sequences_names) %j = sequence
        gt_data{i,j} = dlmread(fullfile(datasets_path, datasets_names{i}, sequences_names{j},'/gt/gt.txt'));
    end
    
end

%% GENERATE DETECTION FROM GT

% ------- GT format -----------------------------------
%   1    2   3  4  5  6    7      8          9
% frame  id  x  y  w  h  active  type  visibility_ratio

% ------- Dets format ----------------------------
%   1    2   3  4  5  6  7   8          9
% frame  -1  x  y  w  h  1  type  visibility_ratio

det_data = [];
option = 'gt';
if strcmp(option, 'gt')
    
    for i = 1:numel(datasets_names) %i = dataset
        
        for j = 1:numel(sequences_names) %j = sequence
            
            index_not_ignored = (gt_data{i,j}(:,7) == 1);
            det_data =  gt_data{i,j}(index_not_ignored,:); %supress non-active gt bboxes
            det_data(:,2) = -1; % suppres id -> -1
            det_data(:,9) = -1; % suppres id -> -does not care
            det_data = sortrows(det_data); % sort by first column (frame)
            
            %         img_path = [datasets_path datasets_names{i} '/' sequences_names{j} '/img1/000001.jpg'];
            %         img= imread(img_path);
            %         img2 = insertShape(img, 'Rectangle', det_data{i,j}(1:20,3:6));
            %         imshow(img2);
            %
            mkdir([detections_path datasets_names{i} '/' sequences_names{j} '/' option '/']);
            detections_file = [detections_path datasets_names{i} '/' sequences_names{j} '/' option '/' sequences_names{j}   '.txt'];
            dlmwrite(detections_file,  det_data);
            
            
        end
        
        
    end
    
end
%% GENERATE DETECTION FROM GT changing P and R
P_range = 0.5 : 0.1 : 1;
R_range = 0.5 : 0.1 : 1;
P_range = [0.5 0.9];
R_range = [0.5 0.9];

sigma_1 = 4;                  % variance for FP positions
sigma_2 = 2;                  % variance for BB sizes

det_data=[];
for i = 1:numel(datasets_names) %i = dataset
    for j = 1:numel(sequences_names) %j = sequenceframes = unique(data(:, 1));
        
        frames = unique(gt_data{i,j}(:, 1));
        n_frames = length(frames);
        
        index_not_ignored = (gt_data{i,j}(:,7) == 1);
        det_data =  gt_data{i,j}(index_not_ignored,:); %supress non-active gt bboxes
        det_data(:,2) = -1; % suppres id -> -1
        det_data(:,9) = -1; % suppres id -> -does not care
        det_data = sortrows(det_data); % sort by first column (frame)
        
        for p = P_range
            for r = R_range
                
                option = sprintf('p%02d_r%02d_s%d_s%d',10*p,10*r,sigma_1,sigma_2)
                
                data_modified = modify_GT_PR(p,r,det_data,sigma_1,sigma_2); % return: 1 -1 bbox
                
                data_modified(:,7) = 1;
                data_modified(:,8) = 1;
                data_modified(:,9) = -1;
                % write detection text file
                mkdir([detections_path datasets_names{i} '/' sequences_names{j} '/' option '/']);
                detections_file = [detections_path datasets_names{i} '/' sequences_names{j} '/' option '/' sequences_names{j}   '.txt'];
                dlmwrite(detections_file, data_modified);
                
            end
        end
        det_data=[];
    end
end
end