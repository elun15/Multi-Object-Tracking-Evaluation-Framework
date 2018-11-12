%%INITIALIZE
clc; clear; close all force;

%% PATH and PARAMETERS

baseFolder = pwd;
datasets_path = [baseFolder '/Datasets/'];
datasets_names_raw = dir(datasets_path);
datasets_names = {};

% Remove '.'and '..' hidden directories
counter_aux=1;
for i=1:length(datasets_names_raw)
    foldername = datasets_names_raw(i).name;
    if ( (strcmp(foldername, '.' ) == 0) && (strcmp(foldername, '..' ) == 0))
        datasets_names{counter_aux} = foldername;
        counter_aux = counter_aux+1;
    end
    
end



%% LOAD DATA
%addpath(genpath('utils'));
gt_data= {};
for i = 1:numel(datasets_names) %i = dataset
    
    sequences_names_raw=dir([datasets_path datasets_names{i}]);
    sequences_names={};
    % Remove '.'and '..' hidden directories
    counter_aux=1;
    for k=1:length(sequences_names_raw)
        foldername = sequences_names_raw(k).name;
        if ( (strcmp(foldername, '.' ) == 0) && (strcmp(foldername, '..' ) == 0))
            sequences_names{counter_aux} = foldername;
            counter_aux = counter_aux+1;
        end
        
    end
    
    for j = 1:numel(sequences_names) %j = sequence
        gt_data{i} = dlmread(fullfile(datasets_path, datasets_names{i}, '/gt/gt.txt'));
        frames = unique(data(:, 1));
        n_frames = length(frames);
        IDs = unique(data(:,2));
        n_people = length(IDs);
    end
    
    
end