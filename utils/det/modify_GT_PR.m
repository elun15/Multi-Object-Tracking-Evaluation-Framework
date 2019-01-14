function [final_data] = modify_GT_PR(p,r,data,sigma_1,sigma_2)
%
% compute constants
frames = unique(data(:, 1));
n_frames = length(frames);

FP = (1 - p) / p;
FN = (1 - r);

final_data = [];
for f = 1 : n_frames
    tfd = data(data(:, 1) == frames(f), 1:7);       % this frame data
    n_people = size(tfd, 1);
    
    %% ADD FP
    fp_n = round(FP*(1-FN)*n_people);               % choose number of people
    fp_idx = randi(n_people, fp_n, 1);              % choose people to affect
    
    false_positives = zeros(fp_n, size(tfd, 2));
    for i = 1 : fp_n
        new_dim = tfd(fp_idx(i), 5:6)./2 + rand*tfd(fp_idx(i), 5:6);
        new_pos = tfd(fp_idx(i), 3:4) + randn(1, 2)*sigma_1^2 - (new_dim-tfd(fp_idx(i), 5:6))./2;
        false_positives(i, :) = [frames(f) -1 new_pos new_dim tfd(fp_idx(i), 7)];
    end
    
    %% MODIFY BB SIZE OPTIONAL/COMMENT
    for i = 1 : size(tfd, 1)
        bb_mod = randn(1, 2)*sigma_2^2;
        tfd(i, 5:6) = tfd(i, 5:6) + bb_mod;
        tfd(i, 3:4) = tfd(i, 3:4) - bb_mod./2;         % otherwise upper left corner is fixed
    end
    
    %% ADD FN
    fn_idx = rand(size(tfd, 1), 1) < FN;
    tfd = tfd(~fn_idx, :);
    
    % finalize results
    final_data = [final_data; tfd; false_positives];
end




end

