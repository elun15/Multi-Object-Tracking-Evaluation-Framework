function loc = checkId(traj,id)

loc = [];

for i = 1:length(traj)
    if traj(i).id == id
        loc = i;
        break
    else
        loc = [];
    end
end