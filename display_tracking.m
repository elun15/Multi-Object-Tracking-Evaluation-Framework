% Routine to display tracking results of one or several trackers with
% selected detections inputs

clc; clear all; close all;

addpath(genpath('./Evaluation'));


sequences= load('./Mat/sequences.mat'); % Sequences info
sequences = sequences.sequences;
results_tracking = load('./Mat/results_tracking.mat'); % Struct with the computed results
results_tracking = results_tracking.results_tracking;
% Select what to display
detection = ['p050_r050_s04_s02'];
dataset = ['Visdrone2018_train']; 
sequence = ['uav0000013_00000_v']; 
tracker = {'SORT'};

displayTracking(sequences, results_tracking,detection, dataset, sequence, tracker);
