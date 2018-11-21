%
% Script to format provided MOT16/17 detections files to the desired format

% ------- Dets original format ----------------------------
%   1    2   3  4  5  6    7     8   9  10
% frame  -1  x  y  w  h  score  -1  -1  -1

% ------- Dets output format ----------------------------
%   1    2   3  4  5  6      7   8      9
% frame  -1  x  y  w  h  active class  -1

% active = 1
% class = 1 (always people in MOT16/17)


%%INITIALIZE
clc; clear; close all force;

%% PATH and PARAMETERS

baseFolder = pwd;
datasets_path = [baseFolder '/Datasets/'];
prov_detections_path = [datasets_path '/Results/Detections/'];

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
det_original_data= {};
det_data= {};
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
        
       
        original_file = fullfile(datasets_path, datasets_names{i}, sequences_names{j},'/det/det.txt');
        det_original_data = dlmread(original_file);
        
        %Check if provided detections are in format MOT16
        if ((det_original_data(1,8) == -1) && (det_original_data(1,9) == -1))
             disp(['Formatting ' datasets_names{i} ' ' sequences_names{j}]);
            mkdir(fullfile(datasets_path, datasets_names{i}, sequences_names{j},'/det_without_format/'));
            without_format_file = fullfile(datasets_path, datasets_names{i}, sequences_names{j},'/det_without_format/det.txt');
            dlmwrite(without_format_file,  det_original_data); %copy original provided detections to new folder
            new_data = det_original_data;
            new_data(:,7:8)= 1;
            new_data= new_data(:,1:9);
            a=2;
            dlmwrite(original_file,  new_data); %Overwrite detection file with formatted data
        else
             disp(['Already formated ' datasets_names{i} ' ' sequences_names{j}]);
        end
    end
    
end

