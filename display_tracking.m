% Routine to display tracking results of one or several trackers with
% selected detections inputs

clc; clear all; close all;

addpath(genpath('./Evaluation'));


sequences= load('sequences.mat'); % Sequences info
sequences = sequences.sequences;
results_tracking = load('results_tracking.mat'); % Struct with the computed results
results_tracking = results_tracking.results_tracking;
% Select what to display
detection = ['p050_r050_s04_s02'];
dataset = ['MOT16_train']; 
sequence = ['MOT16-02']; 
tracker = {'SORT','MATLAB'};

displayTracking(sequences, results_tracking,detection, dataset, sequence, tracker);
