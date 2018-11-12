%% SAMPLE DEMO TO COMPUTE "INTRAFRAME EFFORT" OR "COMPLEXITY"
%
% Author: Juan Carlos
% Original date: 29/12/2016 (Last edit: 10/01/2017)
close all; clearvars; clc;
addpath('utils','../devkit/utils');

%% SETTINGS

% dataset with ground-truth and detections
% datDir = 'D:/datasets/MOT/2DMOT2015/train';                  % JC windows
% datDir = '/Users/poiex/uni/mot_challenge/2DMOT2015/train'; % fabio mac
% datDir = '/home/fabio/Documents/2DMOT2015/train';          % fabio ubuntu
datDir = 'C:/Users/poiex_2/Documents/Fabio/2DMOT2015/train/'; % fabio windows

% tracker root dir
%trkDir = '../results_for_evaluation/MHT_V1.0/';    % MHT v1.0
trkDir = '../results_for_evaluation/sort-master/'; % SORT

%  DETECTION AND TRACKING RESULTS
% detector
detDir = 'detections/public_mot15';
% tracker
outDir = 'trajectories/public_mot15';

% selected sequences to process
seqmaps = 'seqmaps/public_mot15/mot15-train.txt';
seqmaps = 'seqmaps/public_mot15/mot15-example2.txt'; %two sequences
seqmaps = 'seqmaps/public_mot15/mot15-example1.txt'; %one sequence - TUD-Stadtmitte
seqmaps = 'seqmaps/public_mot15/mot15-example3.txt'; %one sequence - ADL-Rundle-6

% flag to display results for a particular frame
% DISPLAY=-1            -> no display
% DISPLAY=[k1,k2,...]   -> display results for frame k1,k2,...
% DISPLAY=Inf           -> display all frames
% DISPLAY_FRAME = 1:10;
config.DISPLAY_FRAME = -1;

% flag to display results for a particular sequence
% DISPLAY_SEQ=-1          -> no display
% DISPLAY_SEQ=[s1,s2,...] -> display results for sequence s1,s2,...
% DISPLAY_SEQ=Inf         -> display all frames
% DISPLAY_SEQ = 1:2;
config.DISPLAY_SEQ = -1;

config.DISPLAY_COST_A = 0; % display association cost
config.DISPLAY_COST_C = 0; % display cardinality cost
config.DISPLAY_COST_B = 0; % display in the same figure both costs
config.DISPLAY_COST_D = 0; % display in the same figure both costs
config.DISPLAY_COST_E = 1; % display in the same figure both costs
config.DISPLAY_STATS  = 0; % display aggregated stats for all sequences

config.GAMMA = 2;

%call the routine to perform the intraframe evaluation
res = intraframe_evaluation(datDir,[trkDir detDir],[trkDir outDir],[trkDir seqmaps],config);