%   Author : Elena luna
%   VPULab - EPS - UAM

%
% Main routine to generate new detections from GT bounding boxes MODIFYING
% SIZE OF ALL BBOXES (NOT USED)
%
clc; clear all; close all;

addpath(genpath('./Utils/'));

% Paths
baseFolder = pwd;
detections_path = [baseFolder '/Results/Detections_BBmodified/'];
datasets_path = [baseFolder '/Datasets/'];

[datasets_names, datasets_paths] = get_folders(datasets_path);


%% LOAD and save GT data in a structure

gt_data= {};
det_data= [];

for d = 1:numel(datasets_names) %i = dataset
    
    [sequences_names, sequences_paths] = get_folders(datasets_paths{d});
    
    for s = 1:numel(sequences_names) %j = sequence
        gt_data{s,d} = dlmread(fullfile(datasets_path, datasets_names{d}, sequences_names{s},'/gt/gt.txt'));
    end
    
end

% ------- GT format -----------------------------------
%   1    2   3  4  5  6    7      8          9
% frame  id  x  y  w  h  active  type  visibility_ratio

% ------- Dets format ----------------------------
%   1    2   3  4  5  6  7   8          9
% frame  -1  x  y  w  h  1  type  visibility_ratio

%% GENERATE DETECTION FROM GT (keeping all gt boxes)
% detections are save in a .txt file in  ./Results/Detections/..

option = 'gt';

if strcmp(option, 'gt')
    
    for d = 1:size(gt_data,2) %j = dataset
        
        [sequences_names, sequences_paths] = get_folders(datasets_paths{d});
        
        for s = 1:size(gt_data,2) %i = sequence
            
            if (not(isempty(gt_data{s,d}))) % It may be empty, because not all datasets contain same number of sequences
                
                index_not_ignored = (gt_data{s,d}(:,7) == 1);
                det_data =  gt_data{s,d}(index_not_ignored,:); %supress non-active gt bboxes
                det_data(:,2) = -1; % suppres id -> -1
                det_data(:,9) = -1; % suppres id -> -does not care
                det_data = sortrows(det_data); % sort by first column (frame)
                
                %                 img_path = [sequences_paths{s} '/img1/000001.jpg'];
                %                 img= imread(img_path);
                %                 img2 = insertShape(img, 'Rectangle', det_data(1:20,3:6));
                %                 imshow(img2);
                det_path = [detections_path datasets_names{d} '/' sequences_names{s} '/' option '/'];
                if not(exist(det_path))
                    mkdir(det_path);
                end
                
                detections_file = [detections_path datasets_names{d} '/' sequences_names{s} '/' option '/' sequences_names{s}   '.txt'];
                if  exist(detections_file)
                    disp(['Overwritten ' option '/' sequences_names{s} '.txt'])
                else
                    disp(['Written ' option '/' sequences_names{s} '.txt'])
                end
                
                dlmwrite(detections_file,  det_data);
            end
        end
    end
    
end
%% GENERATE DETECTION FROM GT changing P and R

% P_range = 0.5 : 0.1 : 1;
% R_range = 0.5 : 0.1 : 1;
P_range = [0.5 0.9];
R_range = [0.5 0.9];

sigma_1 = 4;                  % variance for FP positions
sigma_2 = 2;                  % variance for BB sizes

for d = 1:size(gt_data,2) %j = dataset
    
    [sequences_names, sequences_paths] = get_folders(datasets_paths{d});
    
    for s = 1:size(gt_data,2) %i = sequence
        
        if (not(isempty(gt_data{s,d}))) % It may be empty, because not all datasets contain same number of sequences
            
            index_not_ignored = (gt_data{s,d}(:,7) == 1);
            det_data =  gt_data{s,d}(index_not_ignored,:); %supress non-active gt bboxes
            det_data(:,2) = -1; % suppres id -> -1
            det_data(:,9) = -1; % suppres id -> -does not care
            det_data = sortrows(det_data); % sort by first column (frame)
            
            for p = P_range
                for r = R_range
                    
                    option = sprintf('p%03d_r%03d_s%02d_s%02d',100*p,100*r,sigma_1,sigma_2);
                    data_modified = modify_GT_PR_modifyBB(p,r,det_data,sigma_1,sigma_2); % return: 1 -1 bbox
                    data_modified(:,7) = 1;
                    data_modified(:,8) = 1;
                    data_modified(:,9) = -1;
                    % write detection text file
                    
                    mkdir([detections_path datasets_names{d} '/' sequences_names{s} '/' option '/']);
                    detections_file = [detections_path datasets_names{d} '/' sequences_names{s} '/' option '/' sequences_names{s}   '.txt'];
                    dlmwrite(detections_file,  data_modified);
                    
                end
            end
        end
        
    end
end
