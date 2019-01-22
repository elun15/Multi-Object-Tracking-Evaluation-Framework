function [] = displayTracking(sequences, results_tracking,detection, dataset, sequence, tracker )

index =strcmp({sequences.(dataset).name},sequence); %index of sequence in the dataset

path_img = fullfile(sequences.(dataset)(index).path,'img1','*.jpg');
path_det = fullfile(sequences.(dataset)(index).detections_path,detection,[sequence '.txt']);
frames = dir(path_img);

position =  [1 50]; % For number frame in imshow

for t = 1:numel(tracker)
    res_data{t} = results_tracking.(detection).(tracker{t}).(dataset)(index).result;
end

det_data = dlmread(path_det);


disp('Displaying...')
for f = 1:numel(frames)
    
    det_bboxes = det_data(det_data(:,1)==f, 3:6);
    p =1;
    
    for t = 1:numel(res_data)
        frame = imread(fullfile(sequences.(dataset)(index).path,'img1',frames(f).name));
        frame2 = frame;
        bboxes = res_data{t}(res_data{t}(:,1)==f, 3:6); % take bboxes at this frame
        
        if ~isempty(bboxes)
            ids = res_data{t}(res_data{t}(:,1)==f, 2);
            frame = insertObjectAnnotation(frame, 'rectangle', bboxes, ids,'FontSize',36,'LineWidth',4);
        end
        
        if ~isempty(det_bboxes)
            frame2 = insertShape(frame2, 'rectangle', det_bboxes,'LineWidth', 4,'Color', 'red');
        end
        
        frame = insertText(frame,position,f,'FontSize',40,'BoxColor','r');
        subplot(numel(tracker),2,p);
        imshow(frame);
        title(['Tracker ' tracker{t} ' with detections ' detection], 'Interpreter', 'None');
        p = p+1;
        
        subplot(numel(tracker),2,p);
        imshow(frame2);
        title(['Detections ' detection], 'Interpreter', 'None');
        p = p+1;
        
    end
    pause();
    
end


disp('Done')

end