function classID = getClassID(className)

fullClassSet = {'ignored','pedestrian','person','bicycle','car','van','truck','tricycle','awningtricycle','bus','motor', 'others'};

[flag, id] = ismember(className, fullClassSet);

if(flag)
    classID = id - 1;
else
    disp(['Class '  className])
    error('error in class name!');
end