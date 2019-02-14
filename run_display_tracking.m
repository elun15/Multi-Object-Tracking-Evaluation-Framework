%   Author : Elena luna
%   VPULab - EPS - UAM

% Routine to display tracking results of one or several trackers with
% selected detections inputs

clc; clear all; close all;

addpath(genpath('./Display'));

sequences= load('./Mat/sequences.mat'); % Sequences info
sequences = sequences.sequences;

results_tracking = load('./Mat/results_tracking.mat'); % Struct with the computed results
results_tracking = results_tracking.results_tracking;

% Select what to display
detection = ['gt'];
dataset = ['MOT16_train']; 
sequence = ['MOT16-04']; 
tracker = {'SORT'};

% main display function
displayTracking(sequences, results_tracking,detection, dataset, sequence, tracker);
