function ltrk = graphLink(traj,gtot)
% This is the function that solves the graph, which is described in the
% paper under the Algorithm 1. If you use this code please cite: F. Poiesi
% and A. Cavallaro, "Tracking multiple high-density homogeneous targets,"
% IEEE Trans. on Circuits and Systems for Video Technology, (to appear).

ltrk = struct('linked',[]);
t = 1;
proc_trks = [];

% graph track linkage
% in the paper the sinks correspond to the columns, the sources
% correspond to rows
%%%%%%%%%%%%%%%%%%%%
for k = 1:size(traj,2)
    % check if the track has been processed, if yes, it means that it
    % has been associated to a previous one
    if ~sum(k==proc_trks)
        kk = k;
        temp_link = kk;

        if sum(gtot(kk,:))
            linking_flag = 0;
            while 1
                % sort son nodes
                [sort_linkable_trk, I] = sort(gtot(kk,:),'descend');
                bool_link = (sort_linkable_trk==0) | (I==kk);
                I(bool_link) = [];
                sort_linkable_trk(bool_link) = [];
                for ind = 1:length(I)
                    % check if max-fwd node has parents
                    [~,Ip] = max(gtot(:,I(ind)));
                    % ~sum(I(ind)==temp_link) condition to ensure that
                    % the link has not been performed previously
                    if (kk==Ip)  && ~sum(I(ind)==temp_link)
                        temp_link = [temp_link I(ind)];
                        linking_flag = 1; % this is used to keep trace of the linking
                        break
                    else
                        linking_flag = 0;
                    end
                end

                % condition used to keep on exploring the nodes to link
                % other tracklets
                if linking_flag
                    kk = temp_link(end);
                    if ~sum(gtot(kk,:))
                        linking_flag = 0;
                    end
                else
                    break
                end
            end
            % removes linked tracklets
            gtot(temp_link,:) = 0;
            gtot(:,temp_link) = 0;
        end
        ltrk(t,1).linked = temp_link;
        t = t + 1;
        % processed tracks
        proc_trks = [proc_trks temp_link];
    end
end
%%%%%%%%%%%%%%%%%%%%