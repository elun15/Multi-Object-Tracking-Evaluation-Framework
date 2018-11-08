function allMets = evaluateTrackingMete(seqmap, resDir, dataDir)

addpath(genpath('.'));

allMets = struct('mets2d', [], 'bmark2d', []);

seqmapFile = fullfile('seqmaps', seqmap);
allSeq = parseSequences(seqmapFile);

nFramesGt = [];
nTargetGt = [];
nFramesEst = [];
nTargetEst = [];

for s = 1:numel(allSeq)
    
    gtStatesFile = fullfile(dataDir, allSeq{s}, 'gt', 'gt.txt'); % ground-truth states
    estStatesFile = fullfile(resDir, [allSeq{s} '.txt']); % estimated states
    
    gtStates = convertTXTToStruct(gtStatesFile, fullfile(dataDir, allSeq{s}));
    estStates = convertTXTToStruct(estStatesFile, fullfile(dataDir, allSeq{s}));
    
    % find positions with valid data
    gtInd = ~~gtStates.X;
    estInd = ~~estStates.X;
    
    % get the number of frames and targets
    [nFramesGt(s), nTargetGt(s)] = size(gtStates.X);
    [nFramesEst(s), nTargetEst(s)] = size(estStates.X);
    
    overlap = cell(1, nFramesEst(s));
    mete = zeros(1, nFramesEst(s));
    
    % process each sequence
    for k = 1:nFramesEst(s)
        
        % find elements for each frame
        idxGt = find(gtInd(k,:));
        idxEst = find(estInd(k,:));
        
        overlap{k} = zeros(numel(idxGt), numel(idxEst));
        
        % compute the spatial overlap
        for gt = 1:numel(idxGt)
            ind = idxGt(gt);
            GT = [gtStates.X(k,ind) - gtStates.W(k,ind)/2 ...
                gtStates.Y(k,ind) - gtStates.H(k,ind) ...
                gtStates.W(k,ind) gtStates.H(k,ind) ];
            
            for es = 1:numel(idxEst)
                ind = idxEst(es);
                ST = [estStates.Xi(k,ind) - estStates.W(k,ind)/2 ...
                    estStates.Yi(k,ind) - estStates.H(k,ind) ...
                    estStates.W(k,ind) estStates.H(k,ind) ];
                
                overlap{k}(gt,es) = boxiou(GT(1),GT(2),GT(3),GT(4),ST(1),ST(2),ST(3),ST(4));
            end
            
        end
        
        [~, cost] = Hungarian(1 - overlap{k});
        
        if (numel(idxGt)==0 && numel(idxEst)==0)
            mete(k) = 0;
        else
            mete(k) = (cost + abs(numel(idxGt) - numel(idxEst))) / max([numel(idxGt), numel(idxEst)]);
        end
        
    end
    
    allMets.mets2d(s).name = allSeq{s};
    allMets.mets2d(s).m = mean(mete);
    allMets.mets2d(s).metek = mete;
end

allMets.bmark2d = mean([allMets.mets2d(:).m]);
