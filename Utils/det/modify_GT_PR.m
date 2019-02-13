% Based on: Solera, F., Calderara, S., & Cucchiara, R. (2015, August).
% Towards the evaluation of reproducible robustness in
% tracking-by-detection. AVSS 2015


% Protocol to modify GT in order to get detections with a given P and R
% sigma 1 controls how far new detections are generated since the original
% bounding box


function [final_data] = modify_GT_PR_keepBB(p,r,data,sigma_1)
%
% compute constants
frames = unique(data(:, 1));
n_frames = length(frames);

FP = (1 - p) / p;
FN = (1 - r);

final_data = [];
for f = 1 : n_frames
    tfd = data(data(:, 1) == frames(f), 1:end);       % this frame data
    n_people = size(tfd, 1);
    
    %% ADD FPmodify_GT_PR_keepBB
    fp_n = round(FP*(1-FN)*n_people);               % choose number of people
    fp_idx = randi(n_people, fp_n, 1);              % choose people to affect
    
    false_positives = zeros(fp_n, size(tfd, 2));
    for i = 1 : fp_n
        new_dim = round(tfd(fp_idx(i), 5:6)./2 + rand*tfd(fp_idx(i), 5:6)); %round
        new_pos = round(tfd(fp_idx(i), 3:4) + randn(1, 2)*sigma_1^2 - (new_dim-tfd(fp_idx(i), 5:6))./2); %round
        false_positives(i, :) = [frames(f) -1 new_pos new_dim tfd(fp_idx(i), 7:end)];
    end
    
    %% ADD FN
    fn_idx = rand(size(tfd, 1), 1) < FN;
    tfd = tfd(~fn_idx, :);
    
    % finalize results
    final_data = [final_data; tfd; false_positives];
end


end

