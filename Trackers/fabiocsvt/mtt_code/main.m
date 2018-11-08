% If you use this code cite: F. Poiesi and A. Cavallaro, "Tracking
% multiple high-density homogeneous targets," IEEE Trans. on Circuits and
% Systems for Video Technology, (to appear). For the details about the
% parameters refer to the paper.
clear; close all; clc

global doBahnhof;
global doSunnyday;
global doPETSS2L1;
global doTUD;

% Set to '1' the results to generate and '0' all the others
doBahnhof = 0;
doSunnyday = 0;
doPETSS2L1 = 1;
doTUD = 0;

% 'hung_tracking' generates short tracks
hung_tracking

% 'graph_tracking' uses the greedy-graph based algorithm to link short
% tracks generated with 'hung_tracking'
graph_tracking