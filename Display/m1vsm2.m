clc; clear all; close all;

% For a specific tracker and sequence, plot MOTA measure with each detections

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


addpath(genpath('./External'));

load('./Mat/sequences.mat'); % Sequences info
load('Mat/results_tracking.mat'); % Struct with the computed results

list_trackers = {'MATLAB','SORT'};
dataset = ['Visdrone2018_train']; % MOT16_train  MOT16_train Visdrone2018_train
%sequence = ['MOT16-02'];
% index =strcmp({sequences.(dataset).name},sequence); %index of sequence in the dataset

list_metrics = [4 5];%[4 15 2 ;% Numbers of metrics to plot
list_detections = fieldnames(results_tracking);

position_subplot=1;

for t = 1:numel(list_trackers)
    data=[];
    metrics_allSequences = struct([]);
    for m = 1:2
        
        % Evaluate each sequence
        for d = 1:numel(list_detections)%columns
            
            metrics_allSequences = struct([]); %reset for each detection
            
            list_sequences = {results_tracking.(list_detections{d}).(list_trackers{t}).(dataset).name};
            
            for s = 1: numel(list_sequences) % concatenate data from all sequences in the dataset
                
                disp(['Tracker ' list_trackers{t}  ' detection ' list_detections{d} ' dataset ' dataset ' sequence ' ...
                    results_tracking.(list_detections{d}).(list_trackers{t}).(dataset)(s).name ...
                    ' metric ' results_tracking.(list_detections{d}).(list_trackers{t}).(dataset)(s).metrics_allClass.names{list_metrics(m)} ]);
                
                
                if isempty(metrics_allSequences)
                    
                    metrics_allSequences= struct(results_tracking.(list_detections{d}).(list_trackers{t}).(dataset)(s).metrics_perClass);
                else
                    metrics_allSequences(end+1) = results_tracking.(list_detections{d}).(list_trackers{t}).(dataset)(s).metrics_perClass;
                 end
                %metsBenchmak = evaluateBenchmark(allMets, world)
                
            end
            
            
            metrics_dataset = evaluateBenchmark(metrics_allSequences, 0);
%             path_results = results_tracking.(list_detections{d}).(list_trackers{t}).(dataset)(index).path;
%             load(fullfile(path_results, 'allClassMets.mat'));
%             
             data(m,d) = metrics_dataset.m(list_metrics(1));
            % [mota_d1 mota__d2,
            % motp_d1 motp_d2]
            
        end
        
        
    end
    
    
    subplot(numel(list_trackers),1,position_subplot);  % Comment for separately plotting
    
    for i = 1:size(data,2)
        plot(data(1,i),data(2,i),'x','MarkerSize',10,'LineWidth',3);
        hold on;
    end
    
    title([list_trackers{t} ' tracker evaluation in ' dataset ' dataset ' ],'Interpreter', 'none','FontSize', 16);
    xlabel(metrics_dataset.names(list_metrics(1)),'FontSize', 16);
    ylabel(metrics_dataset.names(list_metrics(2)),'FontSize', 16);
    leg = legend(list_detections);
    set(leg, 'Interpreter', 'none','FontSize', 10);
    
    position_subplot = position_subplot+1;
end

