%   Author : Elena luna
%   VPULab - EPS - UAM

% This function provides a list of  frame names in a directory (.jpg)

function nameSeqs = findSeqList(seqPath)

d = dir([seqPath '/*.jpg']);
nameSeqs = {d.name}';
nameSeqs(ismember(nameSeqs,{'.','..'})) = [];

end