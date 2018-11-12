clear; clc; close all

doParseResults = 0;

if doParseResults

%     benchmarkDir = '/Users/poiex/uni/mot_challenge/2DMOT2015/train/'; % fabio mac
    benchmarkDir = 'C:/Users/poiex_2/Documents/Fabio/2DMOT2015/train/'; % fabio windows

    tracking_results_fold = '../trackers_sourcecode/sort-master/output/';
    d = dir(tracking_results_fold);

    STDNOISE1 = []; MOTA1 = [];
    STDNOISE2 = []; MOTA2 = [];
    FNNOISE = []; MOTA3 = []; MOTA3_separate = [];
    FPNOISE = []; MOTA4 = [];

    for i = 1:length(d)
        if ( d(i).isdir && length(d(i).name) > 2 )
            fold = [tracking_results_fold d(i).name];
            fid = fopen([fold '/params.txt']);
            txtsc = textscan(fid, '%s');
            fclose(fid);

            stdnoise = [str2num(txtsc{1}{4}) str2num(txtsc{1}{5})];
            fnrate = str2num(txtsc{1}{7});
            maxfpperframe = str2num(txtsc{1}{9});
            fprate = str2num(txtsc{1}{11});

            if stdnoise(1) > 0 && stdnoise(2) == 0 && fnrate == 0 && fprate == 0
                allMets = evaluateTrackingMota('mot15-train.txt', fold, benchmarkDir);
                STDNOISE1 = [STDNOISE1 stdnoise(1)];
                MOTA1 = [MOTA1 allMets.bmark2d(12)];
            end

            if stdnoise(1) == 0 && stdnoise(2) > 0 && fnrate == 0 && fprate == 0
                allMets = evaluateTrackingMota('mot15-train.txt', fold, benchmarkDir);
                STDNOISE2 = [STDNOISE2 stdnoise(2)];
                MOTA2 = [MOTA2 allMets.bmark2d(12)];
            end

            if stdnoise(1) == 0 && stdnoise(2) == 0 && fnrate >= 0 && fnrate < 0.825 && fprate == 0
                allMets = evaluateTrackingMota('mot15-train.txt', fold, benchmarkDir);
                FNNOISE = [FNNOISE fnrate];
                
                if isfield(allMets, 'bmark2d')
                    MOTA3 = [MOTA3 allMets.bmark2d(12)];
                end
                
                if isfield(allMets, 'mets2d')
                    mota_sep = [allMets.mets2d(1).m(12) allMets.mets2d(2).m(12) ...
                            allMets.mets2d(3).m(12) allMets.mets2d(4).m(12) ...
                        allMets.mets2d(5).m(12) allMets.mets2d(6).m(12) ...
                        allMets.mets2d(7).m(12) allMets.mets2d(8).m(12) ... 
                        allMets.mets2d(9).m(12) allMets.mets2d(10).m(12) allMets.mets2d(11).m(12)];
                    MOTA3_separate = [MOTA3_separate ; mota_sep];
                end
            end

            if stdnoise(1) == 0 && stdnoise(2) == 0 && fnrate == 0 && fprate > 0
                allMets = evaluateTracking('mot15-train-sort.txt', fold, benchmarkDir);
                FPNOISE = [FPNOISE fprate];
                MOTA4 = [MOTA4 allMets.bmark2d(12)];
            end
        end
    end
end

if doParseResults
    % this is just for false negative rate noise - to add other results when available
    save mota_res MOTA3 MOTA3_separate FNNOISE allMets
else
    load mota_res
end

[X,I] = sort(FNNOISE);

%--
% figure(1)
% plot(X, MOTA3(I), 'linewidth', 2)
% xlabel('FN rate', 'fontsize', 14)
% ylabel('MOTA', 'fontsize', 14)
% title('2D-MOT15 all sequences', 'fontsize', 16)
% set(1, 'position', [372 239 812 564])

%--
U = unique(X);
MOTA3_sep_average = zeros(size(U,2), size(MOTA3_separate,2));
idx = 1;
for u = U
    noise_bool = X == u;
    MOTA3_sep_average(idx, :) = mean(MOTA3_separate(I(noise_bool),:), 1);
    idx = idx + 1;
end

figure(2)
subplot_rows = 6;
subplot_cols = 2;

font_size = 10;
for i = 1:size(MOTA3_separate,2)
    subplot(subplot_rows, subplot_cols, i)
    plot(U, MOTA3_sep_average(:,i), 'linewidth', 2)
    title(allMets.mets2d(i).name, 'fontsize', 12)
    xlabel('FN rate', 'fontsize', font_size)
    ylabel('MOTA', 'fontsize', font_size)
    set(gca,'fontsize', font_size)
    axis([0 .85 0 100])
end
set(2, 'position', [185    78   338   865])




