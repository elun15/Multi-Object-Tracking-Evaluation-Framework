clear; clc; close all

doTrackingEffort = 0;
doMota = ~doTrackingEffort;

addpath('utils', '../devkit/utils');

%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATASET PATH
% datDir = 'D:/datasets/MOT/2DMOT2015/train';                  % JC windows
% datDir = '/Users/poiex/uni/mot_challenge/2DMOT2015/train'; % fabio mac
% datDir = '/home/fabio/Documents/2DMOT2015/train';          % fabio ubuntu
%dataset_path = 'C:\Users\fabio\Documents\2DMOT2015\train\'; % fabio windows
dataset_path = '../../../Datasets/MOT16/train/'; % fabio windows

%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETECTION AND TRACKING RESULTS
% tracker_name = 'sort-master';
tracker_name = 'FabioCSVT';
res_folds = {'gt', 'gt+bbnoise', 'gt+fn', 'gt+fn+bbnoise', 'gt+fp', 'gt+fp+bbnoise', 'gt+fp+fn', 'gt+fp+fn+bbnoise', 'public-mot15'};

res_root_path = 'C:\Users\fabio\Documents\evaluationwithsort\results_for_evaluation'; % fabio windows

%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
gamma = 2;

if doTrackingEffort
   %%%%%%%%%%%%%%%%%%%%%%%%%%
   % EVALUATION
    eval = struct('tracker', [], 'folder', [], 'seq', [], 'ED', [], 'ET', [], 'S', []);

    for r = 1:numel(res_folds)

        metrics_detection = evaluateTrackingMete('mot15-train.txt', fullfile(res_root_path, tracker_name, 'detections', res_folds{r}), dataset_path);
        metrics_tracking = evaluateTrackingMete('mot15-train.txt', fullfile(res_root_path, tracker_name, 'trajectories', res_folds{r}), dataset_path);

        for s = 1:numel(metrics_detection.mets2d)
            eval(r).seq{s} = metrics_detection.mets2d(s).name;
            eval(r).ED{s} = metrics_detection.mets2d(s).metek;
            eval(r).ET{s} = metrics_tracking.mets2d(s).metek;

            % compute tracking effort for each frame
            eval(r).S{s} = metrics_detection.mets2d(s).metek.^gamma - metrics_tracking.mets2d(s).metek.^gamma;
        end

        eval(r).tracker = tracker_name;
        eval(r).folder = res_folds{r};
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % GRAPH VISUALISATION
    colors = ceil(255.*rand(numel(eval),3))/256;
    figure(12)
    [X,Y] = meshgrid(0:.01:1,0:.01:1);
    Z = X.^2 - Y.^2;
    contourf(X,Y,Z,30)
    set(gca, 'ytick', 0:.1:1, 'yticklabel', 0:.1:1);
    set(gca, 'xtick', 0:.1:1, 'xticklabel', 0:.1:1);
    %axis ij
    colorbar
    set(12, 'position', [38 410 1166 566])
    xlabel('E^d', 'fontsize', 14)
    ylabel('E^t', 'fontsize', 14)
    set(gca, 'fontsize', 14)
    hold on
    legend_cells = cell(1, numel(eval)+1);
    legend_cells{1} = 'isoline graph';
    for r = 1:numel(eval)
        BarED = mean([eval(r).ED{:}]);
        BarET = mean([eval(r).ET{:}]);
        plot(BarED, BarET, 'x', 'markersize', 10, 'linewidth', 2, 'color', colors(r,:))
        legend_cells{r+1} = ['E^d= ' sprintf('%0.2f',BarED) ', E^t= ' sprintf('%0.2f',BarET) ', S= ' sprintf('%0.2f',BarED^gamma^2-BarET^2) ' (' eval(r).folder ')'];
    end
    legend(legend_cells, 'location', 'northeastoutside')
    
elseif doMota
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   % EVALUATION
    eval = struct('tracker', [], 'folder', [], 'seq', [], 'MODAseq', [], 'MODAtot', [], 'MODAK', [], 'MOTAK', []);

    for r = 1:numel(res_folds)
        
        metrics_tracking = evaluateTrackingMota('mot15-train.txt', fullfile(res_root_path, tracker_name, 'trajectories', res_folds{r}), dataset_path);

        for s = 1:numel(metrics_tracking.mets2d)
            eval(r).seq{s} = metrics_tracking.mets2d(s).name;
            eval(r).MODAseq{s} = metrics_tracking.mets2d(s).m(14);
            eval(r).MODAK{s} = metrics_tracking.mets2d(s).modak;
            eval(r).MOTAK{s} = metrics_tracking.mets2d(s).motak;
        end
        
        eval(r).MODAtot = metrics_tracking.bmark2d(14);

        eval(r).tracker = tracker_name;
        eval(r).folder = res_folds{r};
    end
    
    plotResultsMota(eval);
    
end


