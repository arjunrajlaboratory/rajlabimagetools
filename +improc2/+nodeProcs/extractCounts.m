function [cellCounts, guideData, snpAData, snpBData] = extractCounts(tools, cellArrayObj, snpMap)
%Extracts counts for all objects in the directory

tools.iterator.goToFirstObject

guideData = dataset();
snpAData = dataset();
snpBData = dataset();

cellCounts = [];

i = 1;

while(tools.iterator.continueIteration)
    
    results = tools.objectHandle.getData('snpColoc');
    
    guide = dataset(results.data.(snpMap.channels{1}));
    snpA = dataset(results.data.(snpMap.channels{2}));
    snpB = dataset(results.data.(snpMap.channels{3}));
    
    
    cellID = ones(length(guide), 1) * i;
    guide.cellID = cellID;
    
    idx = find(i == cellArrayObj(:,1));
    
    guide.arrayNum = ones(length(guide), 1) * cellArrayObj(i,2);
    guide.objectNum = ones(length(guide), 1)* cellArrayObj(i,3);
    
    guideData = vertcat(guideData, guide);
    
    snpA.cellID = ones(length(snpA), 1) * i;
    snpA.arrayNum = ones(length(snpA), 1) * cellArrayObj(i, 2);
    snpA.objectNum = ones(length(snpA), 1) * cellArrayObj(i, 3);
    
    snpAData = vertcat(snpAData, snpA);
        
    snpB.cellID = ones(length(snpB), 1) * i;
    snpB.arrayNum = ones(length(snpB), 1) * cellArrayObj(i, 2);
    snpB.objectNum = ones(length(snpB), 1) * cellArrayObj(i, 3);
    
    snpBData = vertcat(snpBData, snpB);
    
    cellCounts = vertcat(cellCounts, summary(results.data.(results.snpMap.channels{1}).labels)');
    
    tools.iterator.goToNextObject;
    i = i + 1;
end



cellArrayObj = [];
tools.iterator.goToFirstObject
i = 1;

while(tools.iterator.continueIteration)
    cellArrayObj = [cellArrayObj; i, tools.navigator.currentArrayNum, tools.navigator.currentObjNum];
    tools.iterator.goToNextObject;
    i = i + 1;
end


end

