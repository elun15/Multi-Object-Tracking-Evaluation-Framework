function [perClassMets, allClassMets] = evaluateSequence(sequence,printing,saving)
% Input:
% - seqPath
% Sequence path is the path of all sequences to be evaluated in a single run.
%
% - resPath
% The folder containing the tracking results. Each one should be saved in a
% separate .txt file with the name of the respective sequence
%
% - gtPath
% The folder containing the groundtruth files.
%
% - evalClassSet
% The set of evaluated object category
%
% Output:
% - tendallMets
% Scores for each sequence on the evaluated object category
%
% - allresult
% Aggregate score over all sequences



% benchmark specific properties
world = 0;

% read sequence list
% allSequences = findSeqList(seqPath); % find the sequence list

disp(['Evaluating sequence ' sequence.name ' ...'])
% disp(allSequences');

evalClassSet = {'pedestrian'};

%% PARSE GT

sequenceFolder = fullfile(sequence.path,'img1');
assert(isdir(sequenceFolder), 'Sequence folder %s missing.\n', sequenceFolder);
images = dir(fullfile(sequenceFolder, '*.jpg'));
img = imread(fullfile(sequenceFolder, images(1).name));
[imgHeight, imgWidth, ~] = size(img);

gtFilename = fullfile(sequence.path, 'gt', [ 'gt.txt']);
if(~exist(gtFilename, 'file'))
    error('No annotation files is provided for evaluation.');
end
gtdata = dlmread(gtFilename);

% process/clean groudtruth
clean_gtFilename = fullfile(sequence.path, 'gt', 'gt_clean.txt');
if(~exist(clean_gtFilename, 'file'))
    gtdata = dropObjects(gtdata, gtdata, imgHeight, imgWidth);
    dlmwrite(clean_gtFilename, gtdata);
else
    gtdata = dlmread(clean_gtFilename);
end
% break the groundtruth trajetory with multiple object categories
gtdata = breakGts(gtdata);
gtMat = gtdata;
% split the groundtruth for each object category
gtsortdata = classSplit(gtdata);

name_results=fieldnames(sequence.results_tracking); % All the results for this sequence using different detections.


for d = 1: numel(name_results)
    % parse result
    resPath = getfield(sequence.results_tracking_paths,name_results{d});
    resFilename = fullfile(resPath, [sequence.name '.txt']);
    
    % read result file
    if(exist(resFilename,'file'))
        s = dir(resFilename);
        if(s.bytes ~= 0)
            resdata = dlmread(resFilename);
        else
            resdata = zeros(0,9);
        end
    else
        error('Invalid submission. Result file for sequence %s is missing or invalid\n', resFilename);
    end
    
    % process result
    resdata = dropObjects(resdata, gtdata, imgHeight, imgWidth); % drop objects in ignored region or labeled as "others".
    resdata(resdata(:,1) > max(gtMat(:,1)),:) = []; % clip result to gtMaxFrame (remove errors in frame > gtMaxFrame)
    resMat = resdata;
    
    % split the result for each object category
    ressortdata = classSplit(resdata);
    
    % evaluate sequence per class
    perClassMets = classEval(gtsortdata, ressortdata, evalClassSet, sequence.name); % tendMets(k) k = class
    save([resPath '/perClassMets.mat'],'perClassMets'); % save struct with metrics per class
    
    %tendallMets = [tendallMets,tendMets];
    allClassMets = evaluateBenchmark(perClassMets, world); % unify metrics of all classes
    fprintf(' ********************* Sequence %s Results with %s detections *********************\n', sequence.name,name_results{d});
    if printing == 1
        printMetrics(allClassMets);
    end
    if saving == 1
        save([resPath '/allClassMets.mat'],'allClassMets'); % save struct with metrics per class
    end
    % allresult = cat(1, allresult, tendmetsBenchmark); %concatena por filas
    
    
end

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% %% calculate overall scores
% metsBenchmark = evaluateBenchmark(tendallMets, world);
% allresult = cat(1, allresult, metsBenchmark);
% fprintf('\n');
% fprintf(' ********************* Your VisDrone2018 Results *********************\n');
% printMetrics(metsBenchmark);
% fprintf('\n');

% %% calculate overall scores for each object category
% for k = 1:length(evalClassSet)
%     className = evalClassSet{k};
%     cateallMets = [];
%     curInd = k:length(evalClassSet):length(tendallMets);
%     for i = 1:slength(curInd)
%         cateallMets = [cateallMets, tendallMets(curInd(i))];
%     end
%     metsCategory = evaluateBenchmark(cateallMets, world);
%     metsCategory(isnan(metsCategory)) = 0;
%     fprintf('evaluating tracking %s:\n', className);
%     printMetrics(metsCategory);
%     fprintf('\n');
% end
