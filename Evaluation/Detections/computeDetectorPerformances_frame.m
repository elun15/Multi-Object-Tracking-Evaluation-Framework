function [detP, detR,detF, fn,fp,tp] = computeDetectorPerformances(myDetFrameData, myGtFrameData)
fn = 0;
fp = 0;
tp = 0;


costs = zeros(size(myDetFrameData, 1), size(myGtFrameData, 1));
for i = 1 : size(myDetFrameData, 1)
    for j = 1 : size(myGtFrameData, 1)
        costs(i, j) = 1 - boxiou(myDetFrameData(i, 1), myDetFrameData(i, 2), myDetFrameData(i, 3), myDetFrameData(i, 4), ...
            myGtFrameData(j, 1), myGtFrameData(j, 2), myGtFrameData(j, 3), myGtFrameData(j, 4));
    end
end

% make best matches
[Matching,~] = Hungarian(costs);
[I, J] = find(Matching);

% remove not satisfactory overlaps
for i = 1 : length(I)
    if costs(I(i), J(i)) > 0.5
        Matching(I(i), J(i)) = 0;
    end
end

% count miss detection and false positives
fn = fn + sum(sum(Matching, 1)==0);
fp = fp + sum(sum(Matching, 2)==0);
tp = tp + sum(sum(Matching, 1)==1);


detP = tp / (tp + fp);
detR = tp / (tp + fn);
detF = 2*((detP*detR))/(detP+detR);
end

