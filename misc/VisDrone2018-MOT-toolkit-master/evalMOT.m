clc;
clear all;close all;
warning off all;

% add toolboxes
addpath('display');
addpath('eval');
addpath(genpath('utils'));

evalClassSet = {'pedestrian'};


results_path = '../../Results/Tracking/SORT/'; % result path
detections_path = '../../Results/Detections/';
datasets_names_raw = dir(results_path);
datasets_names = {};
% Remove '.', '..' and readme  directories
counter_aux=1;
for aux=1:length(datasets_names_raw)
    foldername = datasets_names_raw(aux).name;
    if ( (strcmp(foldername, '.' ) == 0) && (strcmp(foldername, '..' ) == 0)  && (strcmp(foldername, 'readme' ) == 0))
        datasets_names{counter_aux} = foldername;
        counter_aux = counter_aux+1;
    end
    
end

for i = 1:numel(datasets_names) %i = dataset
    
    sequences_names_raw=dir([results_path datasets_names{i}]);
    sequences_names={};
    
    % Remove '.'and '..' hidden directories
    counter_aux=1;
    for aux=1:length(sequences_names_raw)
        foldername = sequences_names_raw(aux).name;
        if ( (strcmp(foldername, '.' ) == 0) && (strcmp(foldername, '..' ) == 0))
            sequences_names{counter_aux} = foldername;
            counter_aux = counter_aux+1;
        end
    end
    
    
    for j = 1:numel(sequences_names) %j = sequence
        gtPath = ['../../Datasets/' datasets_names{i} '/' sequences_names{j} '/gt/'];
        seqPath = ['../../Datasets/' datasets_names{i} '/' sequences_names{j} '/img1/'];
        resPath = [results_path datasets_names{i} '/' sequences_names{j}];
        
        detections_names_raw = dir(resPath);
        detections_names = {};
        % Remove '.', '..' and readme  directories
        counter_aux=1;
        
        for aux=1:length(detections_names_raw)
            foldername = detections_names_raw(aux).name;
            if ( (strcmp(foldername, '.' ) == 0) && (strcmp(foldername, '..' ) == 0)  && (strcmp(foldername, 'readme' ) == 0))
                detections_names{counter_aux} = foldername;
                counter_aux = counter_aux+1;
            end
            
        end
        
        for k = 1:numel(detections_names)
            
            resPath = [ results_path   datasets_names{i} '/' sequences_names{j} '/' detections_names{k} '/' ]
            [tendallMets, allresult] = evaluateTracking(seqPath, resPath, gtPath, evalClassSet);
            %gt_data{i,j} = dlmread(fullfile(datasets_path, datasets_names{i}, sequences_names{j},'/gt/gt.txt'));
            
        end
        
        
    end
    
end




% datasetPath = '..\VisDrone2018-MOT-test-challenge\'; % dataset path
detPath = '../../Datasets/'% detection input path
detPath = '/storage-disk/u/elg/Multiple Object Tracking/FasterRCNN-MOT-detections/train';

isSeqDisplay = false; % flag to display the detections
isNMS = true; % flag to conduct NMS
nmsThre = 0.6; % threshold of NMS

evalTask = 'Task4b'; % the evaluated task, i.e, Task4a without detection input and Task4b with detection input
trackerName = 'GOG'; % the tracker name
; % the set of evaluated object category
threSet = [0.5, 0.5, 0.5, 0.5, 0.5]; % the detection score threshold

seqPath= '/storage-disk/u/elg/Multiple Object Tracking/datasets/Visdrone_train';
gtPath = '';
% seqPath = '/storage-disk/u/elg/Multiple Object Tracking/MOT-master-elg/results_MOT/results_ALLtrain_512normalized';

%% run the tracker
% isSeqDisplay, isNMS, detPath, resPath, seqPath, evalClassSet, threSet, nmsThre, trackerName);

%% evaluate the tracker
if(strcmp(evalTask, 'Task4a'))
    [ap, recall, precision] = evaluateTrackA(seqPath, results_path, gtPath, evalClassSet);
elseif(strcmp(evalTask, 'Task4b'))
    [tendallMets, allresult] = evaluateTrackB(seqPath, results_path, gtPath, evalClassSet);
end
