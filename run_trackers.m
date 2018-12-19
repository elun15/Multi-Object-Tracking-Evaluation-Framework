%% Run_trackers
%
%   Author : Elena luna
%   VPULab - EPS - UAM
%

%% INITIALIZE
clc; clear; close all force;



sequences = struct;

%% PATH and PARAMETERS

% TRACKING RESULTS
results_tracking_path = fullfile(pwd, 'Results', 'Tracking');

% DETECTIONS
detections_path = fullfile(pwd, 'Results', 'Detections');

% DATASETS
[datasets_names, datasets_paths] = get_folders([fullfile(pwd, '/Datasets/')]);

% SEQUENCES
num_sequences=1;
for i = 1:numel(datasets_paths)
    
    [sequences_names, sequences_paths] = get_folders(datasets_paths{i});
    
    for j = 1:numel(sequences_paths)
        sequences(num_sequences).name = sequences_names{j};
        sequences(num_sequences).path = sequences_paths{j};
        sequences(num_sequences).dataset_name = datasets_names{i};
        sequences(num_sequences).dataset_path = datasets_paths{i};
        sequences(num_sequences).detections_path = fullfile(detections_path,datasets_names{i},sequences_names{j});
        
        num_sequences = num_sequences + 1;
    end
    
end
num_sequences = num_sequences -1;


%% SELECTED TRACKERS AND METRICS

list_trackers = {'SORT'};
list_detections = {'gt', 'p0.5_r0.5_s4_s2'};


% PERFORM TRACKING

for t = 1:numel(list_trackers)
    for s=1:num_sequences
        for d=1:numel(list_detections)
            
            disp(['Running ' list_trackers{t} ' tracker. ' sequences(s).name ' sequence with ' list_detections{d} ]);
            
            if (strcmp(list_trackers{t},'SORT'))
                
                sequences(s).results_tracking_path = fullfile(results_tracking_path,'SORT', sequences(s).dataset_name, sequences(s).name,list_detections{d});
                
                out = run_SORT(sequences(s),list_detections{d});
                
            end
            
        end
        
    end
end








