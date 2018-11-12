%% INITIALIZE
clc; clear; close all force;

%% PATH and PARAMETERS

baseFolder = pwd;
detections_path = [baseFolder '/Results/Detections/'];
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
        gt_data{i,j} = dlmread(fullfile(datasets_path, datasets_names{i}, sequences_names{j},'/gt/gt.txt'));
    end
    
end

%% GENERATE DETECTION FROM GT

% ------- GT format -----------------------------------
%   1    2   3  4  5  6    7      8          9
% frame  id  x  y  w  h  active  type  visibility_ratio

% ------- Dets format ----------------------------
%   1    2   3  4  5  6  7   8          9
% frame  -1  x  y  w  h  1  type  visibility_ratio

det_data = {};
option = 'gt';

for i = 1:numel(datasets_names) %i = dataset
   
    for j = 1:numel(sequences_names) %j = sequence
        index_not_ignored = (gt_data{i,j}(:,7) == 1);
        det_data{i,j} =  gt_data{i,j}(index_not_ignored,:); %supress non-active gt bboxes
        det_data{i,j}(:,2) = -1; % suppres id -> -1
        det_data{i,j} = sortrows(det_data{i,j}); % sort by first column (frame)
        
%         img_path = [datasets_path datasets_names{i} '/' sequences_names{j} '/img1/000001.jpg'];
%         img= imread(img_path);
%         img2 = insertShape(img, 'Rectangle', det_data{i,j}(1:20,3:6));
%         imshow(img2);
%         
        detections_file = [detections_path datasets_names{i} '/' option '/' sequences_names{j}  '.txt'];
        dlmwrite(detections_file,  det_data{i,j});

    
    end
    
    
end


