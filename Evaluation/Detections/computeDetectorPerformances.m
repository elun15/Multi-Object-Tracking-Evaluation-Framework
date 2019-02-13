
% Given detections and GT of a sequence, it computes P and R of the
% provided detections bboxes

function [detP, detR] = computeDetectorPerformances(myDet, myGt,frames_info, display_flag)
fn = 0;
fp = 0;
tp = 0;


frames = unique(myDet(:, 1));
for f = 1 : length(frames)
    
    myDetFrameData = myDet(myDet(:, 1) == frames(f), 3:6);
    index = (myGt(:, 1) == frames(f)& myGt(:, 7) ~= 0);
    myGtFrameData = myGt(index, 3:6);
    
    % plot bboxes in frame
    if display_flag
        
        frame  = imread(fullfile(frames_info(f).folder,frames_info(f).name));
        frame = insertShape(frame, 'rectangle', myGtFrameData,'LineWidth',4,'Color','green');
        frame = insertShape(frame, 'rectangle', myDetFrameData,'LineWidth',4,'Color','red');
        imshow(frame);
        title(['GT (green) and dets (red) for ' frames_info(f).name])
        pause(0.2);
    end
    
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
end

detP = tp / (tp + fp);
detR = tp / (tp + fn);
end

