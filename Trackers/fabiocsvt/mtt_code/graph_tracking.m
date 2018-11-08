warning off;

trk_folder = './hung_trk/';

% params
%%%%%%%%%%%%%%%%%%%%
% buffer
buf = 25;
tshift = 5;

% affinities
time_gap_overlap = 0;
deltaT = 15;
stdGAP = 10;
stdPOS = 1;
probTH = 0.3;

% minimum track allowed
th_trklen = 5;

% time overlap allowed to merge tracks
th_track_overlap = 0;

% interpolation
itime_th = 4;
pol_deg = 2;
%%%%%%%%%%%%%%%%%%%%

destination_folder = './ggb_trk/';
if ~isdir(destination_folder)
    mkdir(destination_folder);
end

% graph_traj is used to keep updated the current trajectories
graph_traj = struct('id',[],'states',[],'ts',[]);

for i = range(1):tshift:range(2)-buf
    
    % load original tracks and store into the buffer
    %%%%%%%%%%%%%%%%%%%%
    if i == range(1)
        % init tracks within buffer
        trk_file = sprintf('tracks_%06d.mat',range(1));
        load([trk_folder trk_file])
        
        traj = struct('id',[],'states',[],'ts',[],'trkLength',[],'strFrm',[]);
        for k = 1:buf
            trk_file = sprintf('tracks_%06d.mat',i+k-1);
            load([trk_folder trk_file])
            
            for j = 1:length(tracks)
                loc = checkId(traj,tracks(j).id);
                if ~isempty(loc)
                    traj(loc).states = cat(2,traj(loc).states,tracks(j).states(:,end));
                    traj(loc).ts = cat(2,traj(loc).ts,i+k-1);
                elseif (~isempty(tracks(j,1).id))
                    traj(end+1).id = tracks(j,1).id;
                    traj(end).states = tracks(j,1).states(:,end);
                    traj(end).ts = i+k-1;
                    traj(end).strFrm = i+k-1;
                end
            end
        end
        traj(1) = [];
    else
        % shift buffered tracks
        dead_traj = [];
        for k = 1:length(traj)
            ts_ind = traj(k).ts<=i-1;
            traj(k).states(:,ts_ind) = [];
            traj(k).ts(ts_ind) = [];
            if isempty(traj(k).states)
                dead_traj = cat(2,dead_traj,k);
            end
        end
        
        traj(dead_traj) = [];
        
        if i<range(2)-buf-tshift+1
            for k = 1:tshift
                det_file = sprintf('tracks_%06d.mat',i+buf-tshift+(k-1));
                load([trk_folder det_file]);
                for j = 1:length(tracks)
                    loc = checkId(traj,tracks(j,1).id);
                    if ~isempty(loc)
                        traj(loc).states = cat(2,traj(loc).states,tracks(j).states(:,end));
                        traj(loc).ts = cat(2,traj(loc).ts,i+buf-tshift+(k-1));
                    elseif (~isempty(tracks(j,1).id))
                        traj(end+1).id = tracks(j,1).id;
                        traj(end).states = tracks(j,1).states(:,end);
                        traj(end).ts = i+buf-tshift+(k-1);
                        traj(end).strFrm = i+buf-tshift+(k-1);
                    end
                end
            end
        else
            for k = 1:range(2)-(i+buf)+tshift+1
                det_file = sprintf('tracks_%06d.mat',i+buf-tshift+(k-1));
                load([trk_folder det_file])
                for j = 1:length(tracks)
                    loc = checkId(traj,tracks(j,1).id);
                    if ~isempty(loc)
                        traj(loc).states = cat(2,traj(loc).states,tracks(j).states(:,end));
                        traj(loc).ts = cat(2,traj(loc).ts,i+buf-tshift+(k-1));
                    elseif (~isempty(tracks(j,1).id))
                        traj(end+1).id = tracks(j,1).id;
                        traj(end).states = tracks(j,1).states(:,end);
                        traj(end).ts = i+buf-tshift+(k-1);
                        traj(end).strFrm = i+buf-tshift+(k-1);
                    end
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%
    
    if numel(traj)
        % time start - end
        TS = zeros(size(traj,2),1);
        TE = zeros(size(TS));
        % position start - end
        PS = zeros(size(TS,1),2);
        PE = zeros(size(TS,1),2);
        WE = zeros(size(TS,1),1);
        %%%%%%%%%%%%%%%%%%%%
        for k = 1:size(traj,2)
            TS(k) = traj(k).ts(1);
            TE(k) = traj(k).ts(end);
            PS(k,:) = traj(k).states(1:2,1)';
            PE(k,:) = traj(k).states(1:2,end)';
            WE(k,:) = traj(k).states(3,end);
        end
        %%%%%%%%%%%%%%%%%%%%

        % calculates affinities
         %%%%%%%%%%%%%%%%%%%%
        time_gap = zeros(length(TS));
        for k = 1:length(TS)
            time_gap(k,:) = TE(k)-TS';
        end
        time_gap(isinf(time_gap)) = 0;
        time_gap = time_gap.*(time_gap<time_gap_overlap);
        time_gap = abs(time_gap).*(abs(time_gap)<deltaT).*boolean(~eye(size(time_gap)));
        % distance weight - the division by 25 comes from hung_tracking.mat
        ndist = sqrt(pdist2(PE(:,1),PS(:,1)).^2+pdist2(PE(:,2),PS(:,2)).^2);
        % position component
        %gpos = exp(-0.5*(ndist/(2*stdPOS)).^2);
        gpos = exp(-0.5*(ndist./repmat(WE,1,size(PE,1))).^2);
        % time gap component
        gtgap = exp(-time_gap.^2/(2*stdGAP));
        % total affinity
        gtot = (gpos.*gtgap).*boolean(time_gap);
        gtot(gtot<probTH) = 0;
        %%%%%%%%%%%%%%%%%%%%


        % make graph
        %%%%%%%%%%%%%%%%%%%%
        %[r,c,s] = find(gtot);
        %[m,n] = size(gtot);
        %S = sparse(r,c,s,m,n);
        %view(biograph(S,[],'ShowWeights','on','EdgeFontSize',12))
        %%%%%%%%%%%%%%%%%%%%

        % it performs graph matching
        %%%%%%%%%%%%%%%%%%%%
        ltrk = graphLink(traj,gtot);
        %%%%%%%%%%%%%%%%%%%%
        traj_temp = traj; % this is used just for plotting

        dead_traj = [];
        % track linking and interpolation
        %%%%%%%%%%%%%%%%%%%%
        for k = 1:length(ltrk)
            l = ltrk(k,1).linked;
            time = [];
            pos = [];
            bbox = [];
            for j = 1:length(l)
                ts_trk = traj(l(j)).ts;
                pos_trk = traj(l(j)).states(1:2,:);
                bbox_trk = traj(l(j)).states(3:4,:);

                time = [time ts_trk];
                pos = [pos pos_trk];
                bbox = [bbox bbox_trk];
            end

            if size(pos,2)>=itime_th
                itime = time(1):time(end);

                % position interpolation
                pol_pos = min(floor(length(time)/2),pol_deg);
                px = polyfit(time,pos(1,:),pol_pos);
                iposx = polyval(px,itime);
                py = polyfit(time,pos(2,:),pol_pos);
                iposy = polyval(py,itime);
                ipos = [iposx ; iposy];

                % bbox interpolation
                pol_bbox = min(floor(length(time)/2),pol_deg);
                pw = polyfit(time,bbox(1,:),pol_bbox);
                ibboxw = polyval(pw,itime);                
                ph = polyfit(time,bbox(2,:),pol_bbox);
                ibboxh = polyval(ph,itime);
                ibbox = [ibboxw ; ibboxh];
            elseif size(pos,2)>1
                % position interpolation
                itime = time(1):time(end);
                iposx = pchip(time,pos(1,:),itime);
                iposy = pchip(time,pos(2,:),itime);
                ipos = [iposx ; iposy];
                % bbox interpolation
                ibboxw = pchip(time,bbox(1,:),itime);
                ibboxh = pchip(time,bbox(2,:),itime);
                ibbox = [ibboxw ; ibboxh];
            else
                itime = time;
                ipos = pos;
                ibbox = bbox;
            end

            % update 'traj'
            [ml,I] = min(l);
            traj(ml).states = [ipos ; ibbox];
            traj(ml).ts = itime;

            l(I) = [];
            dead_traj = cat(2,dead_traj,l);
        end
        %%%%%%%%%%%%%%%%%%%%
        traj(dead_traj) = [];

        % update track length
        %%%%%%%%%%%%%%%%%%%%
        for k = 1:length(traj)
            traj(k).trkLength = traj(k).ts(end) - traj(k).strFrm + 1;
        end
        %%%%%%%%%%%%%%%%%%%%

        % find overlapping tracks to merge
        dead_traj = [];
        %%%%%%%%%%%%%%%%%%%%
        cand_link = [];
        for k = 1:length(traj)
            if traj(k).trkLength>1
                if traj(k).ts(end)~=i+buf-1 || traj(k).ts(1)~=i
                    cand_link = cat(2,cand_link,k);
                end
            end
        end
        if length(cand_link)>1
            % time start - end (same as above)
            TS = zeros(length(cand_link),1);
            TE = zeros(size(TS));
            % position start - end
            PS = zeros(size(TS,1),2);
            PE = zeros(size(TS,1),2);
            for k = 1:length(cand_link)
                TS(k) = traj(cand_link(k)).ts(1);
                TE(k) = traj(cand_link(k)).ts(end);
                PS(k,:) = traj(cand_link(k)).states(1:2,1)';
                PE(k,:) = traj(cand_link(k)).states(1:2,end)';
            end
            time_gap = zeros(length(TS));
            for k = 1:length(TS)
                time_gap(k,:) = TE(k)-TS';
            end
            % this condition is used to link tracks that are overlapping within a
            % certain time slot. NOTE that if we want to connect tracks that are
            % not overlapping, but far apart, we need to remove >0 and allow
            % negative numbers. They can be merged with methods for
            % re-identification.
            time_gap = time_gap.*(time_gap>0);
            time_gap = time_gap.*(time_gap<th_track_overlap);
            % prepare the new affinity matrix. it is resized to go into the
            % function graphLink()
            gover = zeros(length(traj));
            [r,c] = find(time_gap);
            for k = 1:length(r)
                a = cand_link(r(k));
                b = cand_link(c(k));
                % ia represents the ending tracks, ib the starting tracks
                [C,ia,ib] = intersect(traj(a).ts,traj(b).ts);
                ndist = 0;
                for kk = 1:length(ia)
                    ndist = ndist + sqrt(pdist2(traj(a).states(1,ia(kk)),traj(b).states(1,ib(kk))).^2+pdist2(traj(a).states(2,ia(kk)),traj(b).states(2,ib(kk))).^2);
                end
                gover(a,b) = exp(-0.5*((ndist/length(ia))/(2*stdPOS)).^2);
            end

            gover(gover<probTH) = 0;
            % apply graph matching
            ltrk = graphLink(traj,gover);

            for k = 1:length(ltrk)
                if length(ltrk(k).linked)>1
                    l = ltrk(k).linked;
                    pos = [];
                    bbox = [];
                    time = [];
                    for kk = 1:length(ltrk(k).linked)
                        time = cat(2,time,traj(ltrk(k).linked(kk)).ts);
                        pos = cat(2,pos,traj(ltrk(k).linked(kk)).states(1:2,:));
                        bbox = cat(2,bbox,traj(ltrk(k).linked(kk)).states(3:4,:));
                    end
                    [uniques,numUnique] = count_unique(time);
                    [~,ia,~] = unique(time);
                    temp_pos = zeros(size(pos,1),length(uniques));
                    temp_bbox = zeros(size(bbox,1),length(uniques));
                    temp_pos(:,numUnique==1) = pos(:,ia(numUnique==1));
                    temp_bbox(:,numUnique==1) = bbox(:,ia(numUnique==1));
                    indpos = find(numUnique>1);
                    for jj = 1:length(indpos)
                        temp_pos(:,indpos(jj)) = mean(pos(:,time==uniques(indpos(jj))),2);
                        temp_bbox(:,indpos(jj)) = mean(bbox(:,time==uniques(indpos(jj))),2);
                    end
                    pos = temp_pos;
                    bbox = temp_bbox;
                    time = uniques';

                    % update 'traj'
                    [ml,I] = min(l);
                    traj(ml).states = [pos ; bbox];
                    traj(ml).ts = time;

                    l(I) = [];
                    dead_traj = cat(2,dead_traj,l);
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%
        traj(dead_traj) = [];

        % update track length
        %%%%%%%%%%%%%%%%%%%%
        for k = 1:length(traj)
            traj(k).trkLength = traj(k).ts(end) - traj(k).strFrm + 1;
        end
        %%%%%%%%%%%%%%%%%%%%

        % prune short trajectories
        dead_traj = [];
        %%%%%%%%%%%%%%%%%%%%
        for k = 1:length(traj)
            if ~isempty((i+buf-1) - traj(k).ts)
                time_gap = (i+buf-1) - traj(k).ts(end);
                if (time_gap>=deltaT) || (exp(-time_gap.^2/(2*stdGAP))<probTH)
                    if traj(k).trkLength<=th_trklen
                        dead_traj = cat(2,dead_traj,k);
                    end
                end
            else
                dead_traj = cat(2,dead_traj,k);
            end

        end
        %%%%%%%%%%%%%%%%%%%%
        traj(dead_traj) = [];
    end
    
    % store trajectories
    %%%%%%%%%%%%%%%%%%%%
    for k = 1:tshift
        for kk = 1:length(traj)
            ts_ind = traj(kk).ts<=i+k-1;
            if sum(ts_ind)
                ind = checkId(graph_traj,traj(kk).id);
                if ~isempty(ind)
                    states = traj(kk).states(:,ts_ind);
                    ts = traj(kk).ts(ts_ind);
                    graph_traj(ind).states = cat(2,graph_traj(ind).states,states(:,end));
                    graph_traj(ind).ts = cat(2,graph_traj(ind).ts,ts(end));
                else
                    graph_traj(end+1).id = traj(kk).id;
                    graph_traj(end).states = traj(kk).states(:,ts_ind);
                    graph_traj(end).ts = traj(kk).ts(ts_ind);
                end
            end
        end
        
        dead_traj = [];
        for kk = 1:length(graph_traj)
            if isempty(graph_traj(kk).ts) || graph_traj(kk).ts(end)~=i+k-1
                dead_traj = cat(2,dead_traj,kk);
            end
        end
        graph_traj(dead_traj) = [];
        
        res_file = sprintf('graph_traj_%06d.mat',i+k-1);
        save([destination_folder res_file],'graph_traj');
    end
    
    disp(['Frame ' int2str(i+k-1) ' of ' int2str(range(2)) ' - graph tracking - done']);
    %%%%%%%%%%%%%%%%%%%%
end

% store last trajectories
%%%%%%%%%%%%%%%%%%%%
for k = tshift+1:buf+range(2)-(i+buf)+1
    for kk = 1:length(traj)
        ts_ind = traj(kk).ts<=i+k-1;
        if sum(ts_ind)
            ind = checkId(graph_traj,traj(kk).id);
            if ~isempty(ind)
                states = traj(kk).states(:,ts_ind);
                ts = traj(kk).ts(ts_ind);
                graph_traj(ind).states = cat(2,graph_traj(ind).states,states(:,end));
                graph_traj(ind).ts = cat(2,graph_traj(ind).ts,ts(end));
            else
                graph_traj(end+1).id = traj(kk).id;
                graph_traj(end).states = traj(kk).states(:,ts_ind);
                graph_traj(end).ts = traj(kk).ts(ts_ind);
            end
        end
    end

    dead_traj = [];
    for kk = 1:length(graph_traj)
        if isempty(graph_traj(kk).ts) || graph_traj(kk).ts(end)~=i+k-1
            dead_traj = cat(2,dead_traj,kk);
        end
    end
    graph_traj(dead_traj) = [];

    res_file = sprintf('graph_traj_%06d.mat',i+k-1);
    save([destination_folder res_file],'graph_traj');
    disp(['Frame ' int2str(i+k-1) ' of ' int2str(range(2)) ' - graph tracking - done']);
end


% convert to matrix for evaluation
tracking_res = zeros(1,6);
c = 1;
for t = range(1):range(2)
    res_file = sprintf('%sgraph_traj_%06d.mat',destination_folder,t);
    load(res_file);
    for i = 1:length(graph_traj)
        tracking_res(c,:) = [graph_traj(i).id graph_traj(i).states(1:4,end)' graph_traj(i).ts(end)];
        c = c + 1;
    end
end

fid = fopen(D(d).tracking_res,'w');
for i = 0:max(tracking_res(:,6))
    idx = find(tracking_res(:,6) == i);
    for j = 1:length(idx)
        fprintf(fid,'%d ', tracking_res(idx(j),6)); % frame
        fprintf(fid,'%d ', tracking_res(idx(j),1)); % ID
        fprintf(fid,'%.2f ', tracking_res(idx(j),2)); % upper left x
        fprintf(fid,'%.2f ', tracking_res(idx(j),3)); % upper left y
        fprintf(fid,'%.2f ', tracking_res(idx(j),4)); % bottom right x
        fprintf(fid,'%.2f ', tracking_res(idx(j),5)); % bottom right y
        fprintf(fid,'1 '); % option : score
        fprintf(fid,'-1 '); % 3D bounding box (h)
        fprintf(fid,'-1 '); % 3D bounding box (w)
        fprintf(fid,'-1 '); % 3D bounding box (l)
        fprintf(fid,'\n');
    end
end
fclose(fid);

