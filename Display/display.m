clc; clear all; close all;

% For a specific tracker and dataset, fo or each sequence, barplot MOTA measure with each detections

% {'IFD1','IDP','IDR','Recall','Precision','False Alarm Rate','GT Tracks','Mostly Tracked',
%     'Partially Tracked','Mostly Lost','False Positives','False Negatives','ID Switches',
%     'Fragmentations','MOTA','MOTP','MOTA Log'}

addpath(genpath('./external'));

load('results_tracking.mat'); % Struct with the computed results

tracker = ['SORT'];
dataset = ['MOT16_train'];
metric = 15; %MOTA
list_detections = fieldnames(results_tracking);


data=[];
% Evaluate each sequence
for d = 1:numel(list_detections)%columns
    
    list_sequences = {results_tracking.(list_detections{d}).(tracker).(dataset).name};
    
    for s = 1:numel(list_sequences) %rows
       
        path = results_tracking.(list_detections{d}).(tracker).(dataset)(s).path;
        load(fullfile(path, 'allClassMets.mat'));
        
        data(s,d) = allClassMets.m(metric);
       % [mota_seq1_d1 mota_seq1_d2, mota_seq2_d1 mota_seq2_d2]        
        
    end
    
end


figure;
b = bar(data);
leg = legend(b,list_detections);
set(leg, 'Interpreter', 'none','FontSize', 16);
set(gca,'XTickLabel',list_sequences,'FontSize', 20);
ylabel(allClassMets.names(metric),'FontSize', 20);
title([tracker ' tracker evaluation in ' dataset ' dataset.' ],'Interpreter', 'none','FontSize', 20);

% figure;
% data2 = data';
% 
% w = 1;
% for i = 1: numel(list_detections)
%    bar(data(i,:),w,'FaceColor',[0.2 0.2 0.5])
%    hold on;
%    
% end
% % 
% Y = data(:);
% text([1:length(Y)], Y', num2str(Y','%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')