clc; clear all; close all;

% For a specific tracker and dataset, FOR EACH SEQUENCE, barplot MOTA measure with each detections

% {'IFD1','IDP','IDR','Recall','Precision','False Alarm Rate','GT Tracks','Mostly Tracked',
%     'Partially Tracked','Mostly Lost','False Positives','False Negatives','ID Switches',
%     'Fragmentations','MOTA','MOTP','MOTA Log'}

% metrics contains the following (IDMeasures + ClearMOT)
% [1]   IFD1
% [2]   IDP
% [3]   IDR
% [4]   recall	- percentage of detected targets
% [5]   precision	- percentage of correctly detected targets
% [6]   FAR		- number of false alarms per frame
% [7]   GT        - number of ground truth trajectories
% [8-10] MT, PT, ML	- number of mostly tracked, partially tracked and mostly lost trajectories
% [11]   falsepositives- number of false positives (FP)
% [12]   missed        - number of missed targets (FN)
% [13]  idswitches	- number of id switches     (IDs)
% [14]  FRA       - number of fragmentations
% [15]  MOTA	- Multi-object tracking accuracy in [0,100]
% [16]  MOTP	- Multi-object tracking precision in [0,100] (3D) / [td,100] (2D)
% [17]  MOTAL	- Multi-object tracking accuracy in [0,100] with log10(idswitches)


addpath(genpath('./external'));

load('./Mat/results_tracking.mat'); % Struct with the computed results

list_trackers = {'MATLAB','SORT'};
dataset = ['MOT16_train'];
list_metrics = [4 15]%[4 15 2 3]; % Numbers of metrics to plot
list_detections = fieldnames(results_tracking);

position_subplot=1;
for m = 1:numel(list_metrics)
    
    for t = 1:numel(list_trackers)
        data=[];
        
        % Evaluate each sequence
        for d = 1:numel(list_detections)%columns
            
            list_sequences = {results_tracking.(list_detections{d}).(list_trackers{t}).(dataset).name};
            
            for s = 1:numel(list_sequences) %rows
                
                path = results_tracking.(list_detections{d}).(list_trackers{t}).(dataset)(s).path;
                load(fullfile(path, 'allClassMets.mat'));
                
                data(s,d) = allClassMets.m(list_metrics(m));
                % [mota_seq1_d1 mota_seq1_d2, mota_seq2_d1 mota_seq2_d2]
                
            end
        end
        
        subplot(numel(list_metrics),numel(list_trackers),position_subplot);  % Comment for separately plotting
        %figure;
        b = bar(data);
        
        leg = legend(b,list_detections);
        set(leg, 'Interpreter', 'none','FontSize', 10);
        set(gca,'XTickLabel',list_sequences,'FontSize', 16);
        ylabel(allClassMets.names(list_metrics(m)),'FontSize', 16);
        title([list_trackers{t} ' tracker evaluation in ' dataset ' dataset.' ],'Interpreter', 'none','FontSize', 16);
        position_subplot = position_subplot+1;
        
        %         figure;
        %         b = bar(data);
        %         leg = legend(b,list_detections);
        %         set(leg, 'Interpreter', 'none','FontSize', 10);
        %         set(gca,'XTickLabel',list_sequences,'FontSize', 16);
        %         ylabel(allClassMets.names(list_metrics(m)),'FontSize', 16);
        %         title([list_trackers{t} ' tracker evaluation in ' dataset ' dataset.' ],'Interpreter', 'none','FontSize', 16);
        %
        
        
    end
    
end
