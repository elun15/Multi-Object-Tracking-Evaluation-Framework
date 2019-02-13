% Ref: https://bitbucket.org/amilan/motchallenge-devkit
% Modified by ELena Luna VPU-Lab 

% This function provide evaluation metrics per class for a sequence

function perClassMets = classEval(gtsortdata, ressortdata, evalClassSet, sequenceName)
% (call to this function from toolkit folder)
threshold = 0.5;
world = 0;

structure = [];
for k = 1:length(evalClassSet)
    className = evalClassSet{k};
    classID = getClassID(className);
    [gtdata, resdata] = selectTrackData(gtsortdata, ressortdata, classID);
    if(~isempty(gtdata))
        [metsCLEAR, ~, additionalInfo] = CLEAR_MOT_HUN(gtdata, resdata, threshold, world);
        metsID = IDmeasures(gtdata, resdata, threshold, world);
        mets = [metsID.IDF1, metsID.IDP, metsID.IDR, metsCLEAR];
        %allMets.name = strcat(sequenceName, '(', className, ')');
        structure.name = sequenceName;
        structure.class = className;
        structure.m    = mets;
        structure.IDmeasures = metsID;
        structure.additionalInfo = additionalInfo;
        perClassMets(k) = structure;
    else
        %allMets.name = strcat(sequenceName, '(', className, ')');
        structure.name = sequenceName;
        structure.class = className;
        structure.m    = [];
        structure.IDmeasures = [];
        structure.additionalInfo = [];
        perClassMets(k) = structure;        
    end
end
