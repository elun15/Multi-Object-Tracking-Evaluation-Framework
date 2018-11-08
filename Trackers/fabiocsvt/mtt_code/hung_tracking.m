if doShow
    track_col = ceil(255.*rand(100000,3))/256;
end

affinities_th = 25;

dets = double(dets);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% track init
tracks = struct('id',[],'states',[]);

d_bool = dets(:,5)==range(1);
detx = dets(d_bool,1);
dety = dets(d_bool,2);
W = dets(d_bool,3);
H = dets(d_bool,4);

for j = 1:size(dety,1)
    tracks(j,1).id = j;
    tracks(j,1).states = [detx(j) dety(j) W(j) H(j)]';
end
    
destination_folder = './hung_trk/';
if ~isdir(destination_folder)
    mkdir(destination_folder);
end

res_file = sprintf('tracks_%06d.mat',range(1));
save([destination_folder '/' res_file],'tracks');

past_maxId = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = range(1)+1:range(2)
    
    if ~isempty(tracks(1).id)
        past_states = zeros(length(tracks),4);
        past_ids = zeros(length(tracks),1);
        for k = 1:length(tracks)
            past_ids(k) = tracks(k,1).id;
            past_states(k,:) = tracks(k,1).states(:,end);
        end    
    end

    past_maxId = max([past_maxId max(past_ids)]);
    
    d_bool = dets(:,5)==i;
    detx = dets(d_bool,1);
    dety = dets(d_bool,2);
    W = dets(d_bool,3);
    H = dets(d_bool,4);
    
    gd = [];
    for j = 1:size(dety,1)
        gd = [gd ; [detx(j) dety(j) W(j) H(j)]];
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    new_tracks = struct('id', [], 'states', []);

    if ~isempty(tracks(1).id) && ~isempty(gd)
        
        % computes euclidean distance affinity
        affinities = sqrt(pdist2(past_states(:,1)+past_states(:,3)/2,gd(:,1)+gd(:,3)/2).^2+pdist2(past_states(:,2)+past_states(:,4)/2,gd(:,2)+gd(:,4)/2).^2);
        aff_thr = repmat(past_states(:,3),1,size(gd,1));
        affinities(affinities>=aff_thr) = inf;
        % association from rows to columns: the location of the index is refered to the previous
        % frame, the element values refer to the location of the next frame
        rowsol = munkres(affinities);
        
        % update tracks struct
        ind = 1;
        % update struct with tracked targets
        for k = 1:length(rowsol)
            if rowsol(k)
                new_tracks(ind,1).id = past_ids(k);
                new_tracks(ind,1).states = [tracks(k,1).states gd(rowsol(k),:)'];   
                ind = ind + 1;
            end
        end
        % initialize structs of new targets
        mem = ismember(1:size(gd,1),rowsol(rowsol>0));
        new_mem = find(~mem);
        for k = 1:length(new_mem)
            past_maxId = past_maxId + 1;
            new_tracks(ind,1).id = past_maxId;
            new_tracks(ind,1).states = gd(new_mem(k),:)';
            ind = ind + 1;
        end
        %
        tracks = new_tracks;
        
    elseif isempty(tracks(1).id) && ~isempty(gd)
        
        tracks = struct('id',[],'states',[]);
        for j = 1:size(dety,1)
            past_maxId = past_maxId + 1;
            tracks(j,1).id = past_maxId;
            tracks(j,1).states = [detx(j) dety(j) W(j) H(j)]';
        end
        
    else
        
        tracks = struct('id',[],'states',[]);
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if doShow
        fr = imread(sprintf('%s%06d.jpg',D(d).frames,i));
        imshow(fr)
        hold on
        if ~isempty(tracks(1).id)
            for k = 1:length(tracks)
                rectangle('Position',[tracks(k,1).states(1,end) tracks(k,1).states(2,end) tracks(k,1).states(3,end) tracks(k,1).states(4,end)],'EdgeColor',track_col(tracks(k,1).id,:),'LineWidth',5)
            end
        end
        hold off
        pause(1/10)
        drawnow
    end
    
    res_file = sprintf('tracks_%06d.mat',i);
    save([destination_folder res_file],'tracks');
    if mod(i,100)==0
        disp(['Frame ' int2str(i) ' of ' int2str(range(2)) ' - hungarian tracking - done']);
    end
end