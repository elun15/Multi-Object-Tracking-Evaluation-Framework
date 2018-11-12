clear

% benchmarkDir = '../MOT16/train/';
benchmarkDir = '/Users/poiex/uni/mot_challenge/2DMOT2015/train/'; % paste your folder to MOT15 dataset

% allMets = evaluateTracking('mot16-train-fabio.txt', '../my_results/MOT16/train/', benchmarkDir);
allMets = evaluateTracking('mot15-train-sort.txt', '../sort-master/output/', benchmarkDir);
