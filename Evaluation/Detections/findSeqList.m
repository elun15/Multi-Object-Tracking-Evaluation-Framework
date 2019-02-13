function nameSeqs = findSeqList(seqPath)

d = dir([seqPath '/*.jpg']);
nameSeqs = {d.name}';
nameSeqs(ismember(nameSeqs,{'.','..'})) = [];