function outTable = getAllSpotPositions(channel)
% alexaSpotPos = getAllSpotPositions('alexa');
% Assumes that alexa:Fitted is the fitted spot node name

node = [channel, ':Fitted'];

tools = improc2.launchImageObjectTools;

xCenter = [];
yCenter = [];
zPlane = [];
amps = [];
arrayNum = [];
objNum = [];
cellIsGood = [];
left = [];
top = [];
width = [];
height = [];


while(tools.iterator.continueIteration)

    spotData = getFittedSpots(tools.objectHandle.getData(node));

    xCenter = [xCenter, [spotData.xCenter]];
    yCenter = [yCenter, [spotData.yCenter]];
    zPlane = [zPlane, [spotData.zPlane]];
    amps = [amps, [spotData.amplitude]];
    nSpots = numel([spotData.xCenter]);

    arr = ones(1, nSpots) * tools.navigator.currentArrayNum;
    obj = ones(1, nSpots) * tools.navigator.currentObjNum;
    isG = ones(1, nSpots) * tools.annotations.getValue('isGood');
    
    boundingBox = tools.objectHandle.getBoundingBox;

    arrayNum = [arrayNum, arr];
    objNum = [objNum, obj];
    cellIsGood = [cellIsGood, isG];
    left   = [left,   ones(1,nSpots) * boundingBox(1)];
    top    = [top,    ones(1,nSpots) * boundingBox(2)];
    width  = [width,  ones(1,nSpots) * boundingBox(3)];
    height = [height, ones(1,nSpots) * boundingBox(4)];

    tools.iterator.goToNextObject

end

outTable = table(xCenter', yCenter', zPlane', amps', arrayNum', objNum', cellIsGood', left', top', width', height');
outTable.Properties.VariableNames = {'xCenter','yCenter','zPlane','amplitude','arrayNum','objNum','cellIsGood','left','top','width','height'};

%fName = [channel, 'FittedSpotCoords.csv'];
%write(posDat, fName);