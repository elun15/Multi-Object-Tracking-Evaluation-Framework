%   Author : Elena luna
%   VPULab - EPS - UAM
%

% Only useful if results are saven in double format
% This routine load results tracking mat, rounds them and converts them to
% single format

%% INITIALIZE

clc; clear; close all force;
warning off;
sequences = struct;
addpath(genpath('./Mat/'));
% addpath(genpath('./Utils/'));
% addpath(genpath('./External/'));
% addpath(genpath('./Results/'));

results_tracking = struct;
if exist('./Mat/results_eval_tracking.mat')
    load('./Mat/results_eval_tracking.mat');
end


list_detections = fieldnames(results_tracking);
for d=1:numel(list_detections) % e.g "gt", "p0.5" , "r0.5"
    
    list_trackers= fieldnames(results_tracking.(list_detections{d}));
    
    for t = 1:numel(list_trackers)
        
        list_datasets= fieldnames(results_tracking.(list_detections{d}).(list_trackers{t}));
        
        for dat =1:numel(list_datasets)
            
            list_sequences = {results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat}).name};
            
            for s = 1: numel(list_sequences)
                
                temp = results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat})(s).result;
                results_tracking.(list_detections{d}).(list_trackers{t}).(list_datasets{dat})(s).result = single(round(temp));
                
                disp(['Rounding ' list_trackers{t} ' tracker. ' list_sequences{s} ' sequence with ' list_detections{d} ' detections.']);
                
                
            end
        end
        
    end
end

save('./Mat/results_tracking_rounded.mat','results_tracking')
