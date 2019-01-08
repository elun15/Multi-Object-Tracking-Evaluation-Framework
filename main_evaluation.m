clc; clear all; close all;

load('sequences.mat');

for s = 1:numel(sequences)
    
[tendallMets, allresult] = evaluateSequence(sequences(s));

end
