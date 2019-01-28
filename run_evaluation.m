clc; clear all; close all;

addpath(genpath('./External'), genpath('./Evaluation'));

load('./Mat/sequences.mat'); % Sequences we want to evaluate
load('./Mat/results_tracking.mat'); % Struct with the computed results

list_detections = fieldnames(results_tracking);
%list_detections ={'p050_r050_s04_s02'};

list_datasets = fieldnames(sequences);
list_trackers = {'SORT','MATLAB'};
%list_datasets = {'Visdrone2018_train'};
% list_sequences = {'uav0000013_00000_v'};

% Evaluate each sequence
for d = 1:numel(list_detections)
    
    %     list_trackers = fieldnames(results_tracking.(list_detections{d}));
    
    for t = 1:numel(list_trackers)
        
        %         list_datasets = fieldnames(results_tracking.(list_detections{d}).(list_trackers{t}));
        
        for dat = 1:numel(list_datasets)
            
            printing = 1;
            saving = 1;
            
            list_sequences = {results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat}).name};
            %list_sequences = {sequences.(list_datasets{dat}).name};
            
            for s = 1:numel(list_sequences)
                tic
               % disp(['Evaluating ' list_trackers{t} ' tracker. ' sequences.(list_datasets{dat})(s).name ' sequence with ' list_detections{d} ' detections.']);
               
                [perClass, allClass] = evaluateSequence(sequences.(list_datasets{dat})(s), results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat})(s),printing,saving);
                results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat})(s).metrics_perClass = perClass;
                results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat})(s).metrics_allClass = allClass;
                toc;
            end
        end
    end
    
    end

save('./Mat/results_eval_tracking.mat','results_tracking');

