%   Author : Elena luna
%   VPULab - EPS - UAM

% This script evaluates tracking results, previously computed, and
% store all the metrics in a .mat structure


clc; clear all; close all;

addpath(genpath('./External'), genpath('./Evaluation'));

load('./Mat/sequences.mat'); % Sequences we want to evaluate
load('./Mat/results_tracking.mat'); % Struct with the computed results

if not(exist('./Mat/results_eval_tracking.mat'))
    results_eval_tracking = struct;
else
    results_eval_tracking = load('./Mat/results_eval_tracking.mat');
end


list_detections = fieldnames(results_tracking); %list_detections ={'p050_r050_s04_s02'}; % Uncomment for only evaluate certain detections

list_datasets = fieldnames(sequences); %list_datasets = {'Visdrone2018_train'};  % Uncomment for only evaluate certain detections

list_trackers = {'MATLAB','SORT', 'GOG'}; % Select desired trackers


% Evaluate each sequence
for d = 1:numel(list_detections)
    
       
    for t = 1:numel(list_trackers)
        
               
        for dat = 1:numel(list_datasets)
            
            printing = 0; % flag for displayig metrics in command window
            saving = 1; % flag for saving .mat
            
            list_sequences = {results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat}).name};
                       
            for s = 1:numel(list_sequences)
                if s<11 % limit max number of sequences per dataset to 10 (e.g. Visdrone) due to computational time 
                    
                    disp(['Evaluating ' list_trackers{t} ' tracker. ' sequences.(list_datasets{dat})(s).name ' sequence with ' list_detections{d} ' detections.']);
                    tic
                 
                    % main evaluation function
                    [perClass, allClass] = evaluateSequence(sequences.(list_datasets{dat})(s), results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat})(s),printing,saving);
                    % fill struct with metrics
                    results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat})(s).metrics_perClass = perClass;
                    results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat})(s).metrics_allClass = allClass;
                    
                    %   (Opcion: pensar estrategia para calcular solo lo que no este ya calculado)
                    
                    toc;
                end                
            end
                        
        end
    end
    %     save('./Mat/results_eval_tracking.mat','results_tracking'); 
    
end
% results_tracking = results_eval_tracking.results_tracking;
save('./Mat/results_eval_tracking.mat','results_tracking');

