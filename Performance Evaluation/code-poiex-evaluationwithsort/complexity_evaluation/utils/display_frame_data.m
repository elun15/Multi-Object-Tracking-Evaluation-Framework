function  display_frame_data (filename, ss, kk, idx_gt,idx_es,idx_de,gtInfo,deInfo,esInfo,...
                overlap_gt_de,overlap_gt_es,assoc_gt_de,assoc_gt_es,cost_gt_de,cost_gt_es, doRecordFrames)
            
            
frame = imread(filename);
hfig = figure(10000);
set(10000, 'position', [86 16 1600 944])
subplot 221;
imshow(frame)
title(sprintf('Ground-truth k=%d',kk));
for gt=1:numel(idx_gt)                
    rectangle('Position',[gtInfo.X(kk,idx_gt(gt))-gtInfo.W(kk,idx_gt(gt))/2 ...
        gtInfo.Y(kk,idx_gt(gt))-gtInfo.H(kk,idx_gt(gt)) ...
        gtInfo.W(kk,idx_gt(gt)) gtInfo.H(kk,idx_gt(gt))],'EdgeColor','g')
end

subplot 222;
imshow(frame)
title(sprintf('Tracks k=%d',kk));
for es=1:numel(idx_es)                
    rectangle('Position',[esInfo.Xi(kk,idx_es(es))-esInfo.W(kk,idx_es(es))/2 ...
        esInfo.Yi(kk,idx_es(es))-esInfo.H(kk,idx_es(es)) ...
        esInfo.W(kk,idx_es(es)) esInfo.H(kk,idx_es(es)) ],'EdgeColor','b')
end

subplot 223;
imshow(frame)
title(sprintf('Detection k=%d',kk));
for de=1:numel(idx_de)
    rectangle('Position',deInfo(idx_de(de),3:6),'EdgeColor','r')
end                 

drawnow

if doRecordFrames
    fr = getframe(10000);
    fr = imresize(fr.cdata, [944 1600]);
    if ~exist('./frames', 'dir')
        mkdir('frames')
    end
    imwrite(fr, sprintf('./frames/%02d_%05d.jpg',ss,kk), 'jpg', 'quality', 100);
end

% fprintf('Results for frame %d\n',kk);
% disp('overlap_gt_de: '); disp(num2str(overlap_gt_de)); %e.g. overlap
% disp('Cost Matrix : '); disp(num2str(1 - overlap_gt_de)); %the higher the overlap, the lower the cost
% disp('Association Matrix: '); disp(num2str(assoc_gt_de));            
% disp(['Cost: ' num2str(cost_gt_de, 4)]);% ' - Cost from the sum of M elements: ' num2str(sum(1 - overlap_gt_de(assoc_gt_de{kk}(:)==1)), 4)])                        
% 
% disp('overlap_gt_es: '); disp(num2str(overlap_gt_es)); %e.g. overlap
% disp('Cost Matrix : '); disp(num2str(1 - overlap_gt_es)); %the higher the overlap, the lower the cost
% disp('Association Matrix: '); disp(num2str(assoc_gt_es));            
% disp(['Cost: ' num2str(cost_gt_es, 4)]);% ' - Cost from the sum of M elements: ' num2str(sum(1 - overlap_gt_es(assoc_gt_es{kk}(:)==1)), 4)])            
% 
% pause
% close(hfig);