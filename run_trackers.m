%% Run_trackers
%

%   Author : Elena luna
%   VPULab - EPS - UAM
%

%% INITIALIZE

clc; clear all; close all force;
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

% SEQUENCES
num_sequences=0;
num_datasets=0;

for i = 1:numel(datasets_names)
    
    eval(['sequences.' datasets_names{i} ' = struct ;']);
    [sequences_names, sequences_paths] = get_folders(datasets_paths{i});
    num_datasets = num_datasets+1;
    
    for j = 1:numel(sequences_names)
        num_sequences = num_sequences + 1;
        
        eval(['sequences.' datasets_names{i} '(j).name = sequences_names{j} ;']);
        eval(['sequences.' datasets_names{i} '(j).path = sequences_paths{j} ;']);
        eval(['sequences.' datasets_names{i} '(j).dataset_path = datasets_paths{i} ;']);
        eval(['sequences.' datasets_names{i} '(j).detections_path = fullfile(detections_path,datasets_names{i},sequences_names{j}) ;']);
        
    end
    
end

save('./Mat/sequences.mat','sequences');

%% SELECTED TRACKERS AND METRICS

list_trackers = {'GOG','SORT','MATLAB'}; %'SORT'
list_detections = {'gt'};

% P_range = [0.5 0.9];
% R_range = [0.5 0.9];
P_range = [0.6 0.7 0.8];
R_range = [0.6 0.7 0.8];
sigma_1 = 4;                  % variance for FP positions

for p = P_range
    for r = R_range
        % list_detections{end+1} = sprintf('p%03d_r%03d_s%02d_s%02d',100*p,100*r,sigma_1,sigma_2);
        list_detections{end+1} = sprintf('p%03d_r%03d_s%02d',100*p,100*r,sigma_1);
        
    end
end

%TO DO: comprobar que existen las detecciones seleccionadas, si no, mostrar
%un mensaje y seguir

% PERFORM TRACKING
results_tracking = struct;
if exist('./Mat/results_tracking.mat')
    load('./Mat/results_tracking.mat');
end

for d=1:numel(list_detections) % e.g "gt", "p0.5" , "r0.5"
    
    
    for t = 1:numel(list_trackers)
        
        for dat = 1:(num_datasets)
            
            if not(isfield(results_tracking,(list_detections{d}))) %if not exist the detection field
                results_tracking.(list_detections{d})=struct;
            end
            
            if not(isfield(results_tracking.(list_detections{d}),(list_trackers{t})))
                results_tracking.(list_detections{d}).(list_trackers{t}) = struct;
            end
            
            if not(isfield(results_tracking.(list_detections{d}).(list_trackers{t}),(datasets_names{dat}) ))
                
                results_tracking.(list_detections{d}).(list_trackers{t}).(datasets_names{dat})=struct;
            end
            
            for s = 1: numel(eval(['sequences.' datasets_names{dat} ' ;']))
                if s< 11
                    results_tracking.(list_detections{d}).(list_trackers{t}).(datasets_names{dat})(s).name = sequences.(datasets_names{dat})(s).name;
                    
                    disp(['Running ' list_trackers{t} ' tracker. ' sequences.(datasets_names{dat})(s).name ' sequence with ' list_detections{d} ' detections.']);
                    
                    sequences.(datasets_names{dat})(s).results_tracking_paths  =   fullfile(results_tracking_path,list_trackers{t}, datasets_names{dat}, sequences.(datasets_names{dat})(s).name , list_detections{d});
                    results_tracking.(list_detections{d}).(list_trackers{t}).(datasets_names{dat})(s).path =  sequences.(datasets_names{dat})(s).results_tracking_paths ;
                    
                    tic;
                    
                    path_results=results_tracking.(list_detections{d}).(list_trackers{t}).(datasets_names{dat})(s).path;
                    
                    %% GOG
                    if (strcmp(list_trackers{t},'GOG'))
                        
                        if not(exist(path_results,'dir'))
                            
                            mkdir(path_results);
                            result_matrix = run_tracker_GOG(sequences.(datasets_names{dat})(s), list_detections{d});
                            results_tracking.(list_detections{d}).(list_trackers{t}).(datasets_names{dat})(s).result = single(result_matrix);
                            dlmwrite(fullfile(path_results,[sequences.(datasets_names{dat})(s).name '.txt']),result_matrix);
                        else
                            disp('Already exists.');
                        end
                        
                    end
                    
                    %% SORT
                    if (strcmp(list_trackers{t},'SORT'))
                        
                        if not(exist(path_results,'dir'))
                            result_matrix = run_SORT(sequences.(datasets_names{dat})(s) ,list_detections{d});
                            
                            results_tracking.(list_detections{d}).(list_trackers{t}).(datasets_names{dat})(s).result = single(result_matrix);
                        else
                            disp('Already exists.');
                        end
                        
                    end
                    
                    %% MATLAB
                    
                    if (strcmp(list_trackers{t},'MATLAB'))
                        
                        if not(exist(path_results,'dir'))
                            
                            mkdir(path_results);
                            result_matrix = MotionBasedMultiObjectTrackingExample(sequences.(datasets_names{dat})(s),list_detections{d});
                            
                            results_tracking.(list_detections{d}).(list_trackers{t}).(datasets_names{dat})(s).result = single(round(result_matrix));
                            dlmwrite(fullfile(path_results,[sequences.(datasets_names{dat})(s).name '.txt']),result_matrix);
                            
                        else
                            disp('Already exists.');
                        end
                        
                        
                    end
                    toc;
                    
                end
            end
            
        end
    end
end
save('./Mat/results_tracking.mat','results_tracking')
