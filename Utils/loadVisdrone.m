%
% Main routine to load Visdrone dataset
%

clc; clear all; close all;

addpath(genpath('./../Datasets'));

% Paths
visdrone_path = '/home/vpu/Datasets MOT/VisDrone2018-MOT-train';
annotations_path = fullfile(visdrone_path, 'annotations');
sequences_path = fullfile(visdrone_path, 'sequences');

[annotations_names, annotations_paths] = get_folders(annotations_path);
[sequences_names, sequences_paths] = get_folders(sequences_path);

new_visdrone_path = './Datasets/Visdrone2018_train/';
if not(exist(new_visdrone_path))
    mkdir(new_visdrone_path);
end

addpath(new_visdrone_path);

for s = 1 : numel(annotations_names)
    name =sequences_names{s} ;
    
    new_sequence_path = fullfile(new_visdrone_path, name);
    
    if not(exist(new_sequence_path))
        mkdir(new_sequence_path);
        mkdir(fullfile(new_sequence_path,'gt'));
        mkdir(fullfile(new_sequence_path,'img1'));
    end
    addpath(genpath(new_sequence_path));
    
    % Copy gt and images to the new location
    disp (['Loading gt sequence  ' annotations_names{s} ]);
    copyfile(annotations_paths{s},fullfile(new_sequence_path,'gt','gt.txt'));
    disp (['Loading images from  sequence  ' sequences_names{s} ]);
    copyfile(sequences_paths{s},fullfile(new_sequence_path,'img1'));
    
    
end
