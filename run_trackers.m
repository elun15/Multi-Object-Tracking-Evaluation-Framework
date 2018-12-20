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
list_detections = {'gt'};

P_range = [0.5 0.9];
R_range = [0.5 0.9];
sigma_1 = 4;                  % variance for FP positions
sigma_2 = 2;                  % variance for BB sizes

for p = P_range
    for r = R_range
        list_detections{end+1} = sprintf('p%02d_r%02d_s%d_s%d',10*p,10*r,sigma_1,sigma_2);
    end
end


% PERFORM TRACKING

for t = 1:numel(list_trackers)
    for s=1:num_sequences
        for d=1:numel(list_detections)
            
            disp(['Running ' list_trackers{t} ' tracker. ' sequences(s).name ' sequence with ' list_detections{d} ]);
            
            if (strcmp(list_trackers{t},'SORT'))
                
                sequences(s).results_tracking_path = fullfile(results_tracking_path,'SORT', sequences(s).dataset_name, sequences(s).name,list_detections{d});
                
                eval(['sequences(s).results_tracking_' list_detections{d} '= run_SORT(sequences(s),list_detections{d});']);
                
            end
            
        end
        
    end
end



save('sequences.mat','sequences')



