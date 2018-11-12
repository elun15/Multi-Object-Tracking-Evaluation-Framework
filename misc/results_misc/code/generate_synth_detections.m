clear; clc; close all

% root_path_mot15 = '/home/fabio/Documents/2DMOT2015/'; % Fabio Ubuntu
root_path_mot15 = '/Users/poiex/uni/mot_challenge/2DMOT2015/'; % Fabio Mac

detections_destination_folder = '../MHT_V1.0/detections/gt+fp+fn/';

% miss-detection probability (false negatives)
ms_det_prob = 0.3;

% false-alarm rate (false positives)
fa_rate = 0.3;
max_fapf = 10; % max false alarms per frame

% state noise (standard deviation)
% [position bounding_box]
state_noise = [0 0];

% dataset - MOT15 - https://motchallenge.net/data/2D_MOT_2015/
D = struct('dataset', [], 'gt', [], 'frame_size', [], 'length', []);

D(1).dataset = 'ADL-Rundle-6'; 
D(1).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(1).dataset,'gt/gt.txt'));
D(1).frame_size = [1080 1920];
D(1).length = 525;

D(2).dataset = 'ADL-Rundle-8';
D(2).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(2).dataset,'gt/gt.txt'));
D(2).frame_size = [1080 1920];
D(2).length = 654;

D(3).dataset = 'ETH-Bahnhof'; 
D(3).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(3).dataset,'gt/gt.txt'));
D(3).frame_size = [480 640];
D(3).length = 1000;

D(4).dataset = 'ETH-Pedcross2'; 
D(4).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(4).dataset,'gt/gt.txt'));
D(4).frame_size = [480 640];
D(4).length = 837;

D(5).dataset = 'ETH-Sunnyday'; 
D(5).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(5).dataset,'gt/gt.txt'));
D(5).frame_size = [480 640];
D(5).length = 354;

D(6).dataset = 'KITTI-13'; 
D(6).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(6).dataset,'gt/gt.txt'));
D(6).frame_size = [375 1242];
D(6).length = 340;

D(7).dataset = 'KITTI-17'; 
D(7).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(7).dataset,'gt/gt.txt'));
D(7).frame_size = [370 1224];
D(7).length = 145;

D(8).dataset = 'PETS09-S2L1'; 
D(8).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(8).dataset,'gt/gt.txt'));
D(8).frame_size = [576 768];
D(8).length = 795;

D(9).dataset = 'TUD-Campus'; 
D(9).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(9).dataset,'gt/gt.txt'));
D(9).frame_size = [480 640];
D(9).length = 71;

D(10).dataset = 'TUD-Stadtmitte'; 
D(10).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(10).dataset,'gt/gt.txt'));
D(10).frame_size = [480 640];
D(10).length = 179;

D(11).dataset = 'Venice-2'; 
D(11).gt  = dlmread(fullfile(root_path_mot15,'/train/',D(11).dataset,'gt/gt.txt'));
D(11).frame_size = [1080 1920];
D(11).length = 600;

fid = fopen(fullfile(detections_destination_folder,'config.txt'),'w');
fprintf(fid, 'miss-detection probability: %0.4f\n', ms_det_prob);
fprintf(fid, 'false alarm rate: %0.4f\n', fa_rate);
fprintf(fid, 'max false alarm per frame: %d\n', max_fapf);
fprintf(fid, 'state noise (standard deviation): [%0.4f %0.4f]\n', state_noise(1), state_noise(2));
fclose(fid);


for d = 1:length(D)
    
    gt = D(d).gt;
    
    % input to hung_tracking
    range = [min(gt(:, 1)) max(gt(:, 1))];
    dets = [gt(:, 3:6) gt(:, 1)];
    
    mean_state = mean(dets,1);
    std_state = std(dets,1);
    
    % simulate different detectors
    % by applying increasing noise I would like to see the same trend by
    % using the new measure, whereas I am expecting to see not a regular
    % trend with the original MOTA
    %------------------------------
    % apply state noise
    position_noise = state_noise(1) * randn(size(dets,1), 2);
    bounding_box_noise = state_noise(2) * randn(size(dets,1), 2);
    
    dets(:, 1:2) = round(dets(:, 1:2) + position_noise);
    dets(:, 3:4) = round(dets(:, 3:4) + bounding_box_noise);
    
    % apply miss detection noise
    missed_detections = rand(size(dets,1), 1) < ms_det_prob;
    
    dets(missed_detections, :) = [];
    
    % apply false alarm noise
    dets_temp = [];
    for i = 1:D(d).length
        bool_fr_num = dets(:,5) == i;
        dets_temp = [dets_temp ; dets(bool_fr_num, :)];
        
        % generate false alarm states
        fa = [D(d).frame_size(2)*rand(max_fapf, 1) D(d).frame_size(1)*rand(max_fapf, 1) mean_state(3)+2*std_state(3)*rand(max_fapf, 1) mean_state(4)+2*std_state(4)*rand(max_fapf, 1) i*ones(max_fapf, 1)];
        
        % apply the false alarm rate probability
        fa(rand(max_fapf,1) > fa_rate, :) = [];
        
        % add the false alarms to the detections
        dets_temp = [dets_temp ; fa];
    end
    dets = dets_temp;
    
    
    fid = fopen(fullfile(detections_destination_folder,[D(d).dataset '.txt']),'w');
    for i = 0:max(dets(:,5))
        idx = find(dets(:,5) == i);
        for j = 1:length(idx)
            fprintf(fid,'%d,', dets(idx(j),5)); % frame
            fprintf(fid,'-1,'); % ID
            fprintf(fid,'%.2f,', dets(idx(j),1)); % upper left x
            fprintf(fid,'%.2f,', dets(idx(j),2)); % upper left y
            fprintf(fid,'%.2f,', dets(idx(j),3)); % bbx
            fprintf(fid,'%.2f,', dets(idx(j),4)); % bby
            fprintf(fid,'1,'); % option : score
            fprintf(fid,'-1,'); % 3D bounding box (h)
            fprintf(fid,'-1,'); % 3D bounding box (w)
            fprintf(fid,'-1'); % 3D bounding box (l)
            fprintf(fid,'\n');
        end
    end
    fclose(fid);
    
end







