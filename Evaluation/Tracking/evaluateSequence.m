% ELena Luna VPU-Lab
% This function provides tracking evaluation metrics per class and per sequence

function [perClassMets, allClassMets] = evaluateSequence(sequence_info,sequence_results,printing,saving)
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

disp(['Evaluating sequence ' sequence_info.name ' ...'])

%% PARSE GT

sequenceFolder = fullfile(sequence_info.path,'img1');
assert(isdir(sequenceFolder), 'Sequence folder %s missing.\n', sequenceFolder);
images = dir(fullfile(sequenceFolder, '*.jpg'));
img = imread(fullfile(sequenceFolder, images(1).name));
[imgHeight, imgWidth, ~] = size(img);

gtFilename = fullfile(sequence_info.path, 'gt', [ 'gt.txt']);
if(~exist(gtFilename, 'file'))
    error('No annotation files is provided for evaluation.');list_detections
end

gtdata = dlmread(gtFilename);

% process/clean groudtruth

clean_gtFilename = fullfile(sequence_info.path, 'gt', 'gt_clean.txt');
gtdata = dropObjects(gtdata, gtdata, imgHeight, imgWidth);
if(~exist(clean_gtFilename, 'file'))%borrar
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

% parse result
resPath = (sequence_results.path);
[~,name_detection,~] = fileparts(resPath);
resFilename = fullfile(resPath, [sequence_info.name '.txt']);
resdata = sequence_results.result;


% process result
resdata = dropObjects(resdata, gtdata, imgHeight, imgWidth); % drop objects in ignored region or labeled as "others".
resdata(resdata(:,1) > max(gtMat(:,1)),:) = []; % clip result to gtMaxFrame (remove errors in frame > gtMaxFrame)
resMat = resdata;

% split the result for each object category
ressortdata = classSplit(resdata);

% extract evalClassSet automatically from the results
index = not(( structfun(@isempty, ressortdata) ));
names = fieldnames(ressortdata);
evalClassSet ={names{index}};

% evaluate sequence per class
perClassMets = classEval(gtsortdata, ressortdata, evalClassSet, sequence_info.name); % tendMets(k) k = class

% save([resPath '/perClassMets.mat'],'perClassMets'); % save struct with metrics per class

allClassMets = evaluateBenchmark(perClassMets, world); % unify metrics of all classes

fprintf(' ********************* Sequence %s Results with %s detections *********************\n', sequence_info.name,name_detection);
if printing == 1
    printMetrics(allClassMets.m);
end

if saving == 1
    % save([resPath '/allClassMets.mat'],'allClassMets'); % save struct with metrics per class
end
% allresult = cat(1, allresult, tendmetsBenchmark); %concatena por filas

end
