clc; clear all; close all;

%% This script saves a struct with detections evaluation per sequence and dataset
%performances.dataset:
% name sequence1  name sequence1
% Precision          Precision
% Recall             Recall
% GT obj / frame
% det obj / frame

addpath(genpath('./Evaluation/Detections'));
addpath(genpath('./Detections'));
addpath(genpath('./Utils'));



% DATASETS
[datasets_names, datasets_paths] = get_folders([fullfile(pwd, '/Detections/')]);
detections = struct;
num_datasets = 0;
if not(exist('./Mat/detections.mat'))
    for dat = 1:numel(datasets_names)
        
        [detectors_names, detectors_paths] = get_folders(datasets_paths{dat});
        
        for det = 1:numel(detectors_names)
            [sequences_names, sequences_paths] = get_folders(detectors_paths{det});
            
            detections.(datasets_names{dat}).(detectors_names{det})= sequences_names;
        end
    end
    
    save('./Mat/detections.mat','detections');
else
    load('./Mat/detections.mat');
end

performances = detections;

list_datasets = fieldnames(detections);

display_flag = 0;

for dat = 1:numel(list_datasets)
    
    list_detectors = fieldnames(detections.(list_datasets{dat}));
    
    for det = 1:numel(list_detectors)
        list_sequences = detections.(list_datasets{dat}).(list_detectors{det});
        
        for s = 1:numel(list_sequences)
            disp(['Evaluating ' list_datasets{dat} ' dataset. ' list_detectors{det} ' detector in ' list_sequences{s} ' sequence.']);
            
            if strcmp(list_datasets{dat},'Visdrone2018_train')
                
                [filepath,name,ext] = fileparts( list_sequences{s});
                gt_file = fullfile('./Datasets/Visdrone2018_train/' , name,'gt','gt.txt');
                det_file = fullfile(datasets_paths{dat},list_detectors{det},list_sequences{s}); % not filtered
                frames_path = fullfile(['./Datasets/' datasets_names{dat} ], name,'img1','*.jpg');
                display_flag = 1;
                
            else % MOT17_train
                gt_file = fullfile(datasets_paths{dat},list_detectors{det},list_sequences{s},'gt','gt.txt');
                det_file = fullfile(datasets_paths{dat},list_detectors{det},list_sequences{s},'det','det.txt');
                frames_path = fullfile(['./Datasets/' datasets_names{dat} ], list_sequences{s},'img1','*.jpg');
            end
            
            gt_data = dlmread(gt_file);
            det_data = dlmread(det_file);
            
            if strcmp(list_datasets{dat},'Visdrone2018_train')
                det_data = det_data(det_data(:,7) >= 0.6,:); % filter by score >= 0.6
                
            end
            
            frames = dir(frames_path); % for display
            
            [detP, detR] = computeDetectorPerformances(det_data, gt_data, frames, display_flag);
            % performance struct 
            performances.(list_datasets{dat}).(list_detectors{det})(2,s) = {detP};
            performances.(list_datasets{dat}).(list_detectors{det})(3,s) = {detR};
            performances.(list_datasets{dat}).(list_detectors{det})(4,s) = {size(det_data,1) / max(det_data(:,1))};
            performances.(list_datasets{dat}).(list_detectors{det})(5,s) = {size(gt_data,1) / max(gt_data(:,1))};

            
        end
        
    end
    
end
save('./Mat/detections_performance.mat','performances');

