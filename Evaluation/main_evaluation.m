clc; clear all; close all;

addpath(genpath('./external'));

load('results_tracking.mat');

list_detections = fieldnames(results_tracking);


% Evaluate each sequence
for d = 1:numel(list_detections)
    
    list_trackers = fieldnames(results_tracking.(list_detections{d}));
    
    for t = 1:numel(list_trackers)
        
        list_datasets = fieldnames(results_tracking.(list_detections{d}).(list_trackers{t}));
      
        for dat = 1:numel(list_datasets)
            
            printing = 1;
            saving = 1;
            
            list_sequences = {results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat}).name};
                       
           
            [perClass, allClass] = evaluateSequence(results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat})(1),printing,saving);
            results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat}).metrics.perClass = perClass;
            results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat}).metrics.allClass = allClass;
        end
    end
    
    
end

results_evaltracking = results_tracking;
save('results_evaltracking.mat','results_evaltracking')

