%% Run_trackers
%

%   Author : Elena luna
%   VPULab - EPS - UAM
%

%% INITIALIZE

clc; clear; close all force;
warning off;
sequences = struct;
addpath(genpath('./Trackers/'));
addpath(genpath('./Utils/'));
addpath(genpath('./External/'));
addpath(genpath('./Results/'));

%% PATH and PARAMETERS

% TRACKING RESULTS
results_tracking_path = fullfile(pwd, 'Results', 'Tracking');

% DETECTIONS
detections_path = fullfile(pwd, 'Results', 'Detections');

% DATASETS
[datasets_names, datasets_paths] = get_folders([fullfile(pwd, '/Datasets/')]);

%% SELECTED TRACKERS AND METRICS

list_trackers = {'GOG','SORT','MATLAB'}; %'SORT'
list_detections = {'gt'};


%TO DO: comprobar que existen las detecciones seleccionadas, si no, mostrar
%un mensaje y seguir

% PERFORM TRACKING
results_tracking = struct;
if exist('./Mat/results_tracking.mat')
    load('./Mat/results_tracking.mat');
end

list_detections = fieldnames(results_tracking);
for d=1:numel(list_detections) % e.g "gt", "p0.5" , "r0.5"
    
    list_trackers= fieldnames(results_tracking.(list_detections{d}));
    
    for t = 1:numel(list_trackers)
        
        list_datasets= fieldnames(results_tracking.(list_detections{d}).(list_trackers{t}));
        
        for dat =1:numel(list_datasets)
            l
            list_sequences = {results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat}).name};
            
            for s = 1: numel(list_sequences)
               
                    temp = results_tracking.(list_detections{d}).(list_trackers{t}).(datasets_names{dat})(s).result;
                    results_tracking.(list_detections{d}).(list_trackers{t}).(datasets_names{dat})(s).result = single(round(temp));
                    
                    disp(['Rounding ' list_trackers{t} ' tracker. ' list_sequences{s} ' sequence with ' list_detections{d} ' detections.']);
                    
                   
                    
                    
                end
            end
            
        end
    end

save('./Mat/results_tracking_rounded.mat','results_tracking')
