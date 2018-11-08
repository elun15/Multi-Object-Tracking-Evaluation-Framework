clear; clc; close all

doParseResults = 1;

if doParseResults

    % paste your folder to MOT15 dataset
%     benchmarkDir = '/Users/poiex/uni/mot_challenge/2DMOT2015/train/'; % fabio Mac
    benchmarkDir = 'C:/Users/poiex_2/Documents/Fabio/2DMOT2015/train/'; % fabio Windows
    
    estStateFold = '../trackers_sourcecode/sort-master/output/';
    d = dir(estStateFold);

    METE3 = [];
    mete_sep = [];
    METE3_separate = [];
    FNNOISE = [];

    for i = 1:length(d)
        if ( d(i).isdir && length(d(i).name) > 2 )
            fold = [estStateFold d(i).name];
            fid = fopen([fold '/params.txt']);
            txtsc = textscan(fid, '%s');
            fclose(fid);
            
            stdnoise = [str2num(txtsc{1}{4}) str2num(txtsc{1}{5})];
            fnrate = str2num(txtsc{1}{7});
            maxfpperframe = str2num(txtsc{1}{9});
            fprate = str2num(txtsc{1}{11});

            if stdnoise(1) == 0 && stdnoise(2) == 0 && fnrate >= 0 && fnrate < 0.825 && fprate == 0
                allMets = evaluateTrackingMete('mot15-train.txt', fold, benchmarkDir);
                FNNOISE = [FNNOISE fnrate];
                
                if isfield(allMets, 'bmark2d')
                    METE3 = [METE3 allMets.bmark2d];
                end
                
                if isfield(allMets, 'mets2d')
                    mete_sep = [allMets.mets2d(1).m allMets.mets2d(2).m ...
                            allMets.mets2d(3).m allMets.mets2d(4).m ...
                        allMets.mets2d(5).m allMets.mets2d(6).m ...
                        allMets.mets2d(7).m allMets.mets2d(8).m ... 
                        allMets.mets2d(9).m allMets.mets2d(10).m allMets.mets2d(11).m];
                    METE3_separate = [METE3_separate ; mete_sep];
                end
            end
        end
    end
end

if doParseResults
    % this is just for false negative rate noise - to add other results when available
    save mete_res METE3 METE3_separate FNNOISE allMets
else
    load METE_res
end

[X,I] = sort(FNNOISE);

%--
% figure(1)
% plot(X, METE3(I), 'linewidth', 2)
% xlabel('FN rate', 'fontsize', 14)
% ylabel('METE', 'fontsize', 14)
% title('2D-MOT15 all sequences', 'fontsize', 16)
% set(1, 'position', [372 239 812 564])

%--
U = unique(X);
METE3_sep_average = zeros(size(U,2), size(METE3_separate,2));
idx = 1;
for u = U
    noise_bool = X == u;
    METE3_sep_average(idx, :) = mean(METE3_separate(I(noise_bool),:), 1);
    idx = idx + 1;
end

figure(2)
subplot_rows = 6;
subplot_cols = 2;

font_size = 10;
for i = 1:size(METE3_separate,2)
    subplot(subplot_rows, subplot_cols, i)
    plot(U, METE3_sep_average(:,i), 'linewidth', 2)
    title(allMets.mets2d(i).name, 'fontsize', 12)
    xlabel('FN rate', 'fontsize', font_size)
    ylabel('METE', 'fontsize', font_size)
    set(gca,'fontsize', font_size)
    axis([0 .85 0 1])
end
set(2, 'position', [185    78   338   865])




