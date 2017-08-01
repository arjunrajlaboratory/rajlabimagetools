% Documents shift corrrection from Ally's bead experiments for ExFISH.

% The two folders are located in:
% https://www.dropbox.com/sh/z1rgmjnf02l6q2m/AAAlRyvLYs7DJL8r5d4NcHUZa?dl=0
% local paths are:
beadPath1 = '~/Dropbox (RajLab)/DataArchive/ShiftCorrectionData/AllyExM_2017_07_31/2017-04-27_beads_in_gels/expanded_beads';
beadPath2 = '~/Dropbox (RajLab)/DataArchive/ShiftCorrectionData/AllyExM_2017_07_31/2017-04-17_beads/beads_05um/03_stepsize';
% file itself will be stored at (varies depending on where you keep repo):
outFile = '~/code/rajlabimagetools/shiftCorrections/Scope2_2017_07_31_AllyExM.csv';

% For each folder:
%% First ran:
% improc2.segmentGUI.SegmentGUI;
% Segmented just one object per field of view (encompassing all spots)
% improc2.processImageObjects()
% improc2.launchThresholdGUI;
% Thresholded all spots manually.

%% Then ran code to do fitting
% Note that running this can take a while. Commented out for time being.

% dataAdder = improc2.processing.DataAdder();
% 
% unprocessedFittedData = improc2.nodeProcs.TwoStageSpotFitProcessedData();
% 
% dataAdder.addDataToObject(unprocessedFittedData, 'alexa', 'alexa:Fitted')
% dataAdder.addDataToObject(unprocessedFittedData, 'cy', 'cy:Fitted')
% dataAdder.addDataToObject(unprocessedFittedData, 'tmr', 'tmr:Fitted')
% dataAdder.addDataToObject(unprocessedFittedData, 'gfp', 'gfp:Fitted')
% 
% dataAdder.repeatForAllObjectsAndQuit();
% improc2.processing.updateAll

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First, do folder 1
cd(beadPath1);

%% Pull out spot positions
alexaSpots = shiftCorrectCodes.getAllSpotPositions('alexa');
gfpSpots = shiftCorrectCodes.getAllSpotPositions('gfp');
cySpots = shiftCorrectCodes.getAllSpotPositions('cy');
tmrSpots = shiftCorrectCodes.getAllSpotPositions('tmr');

alexaSpots = alexaSpots(alexaSpots.cellIsGood==1,:);
gfpSpots = gfpSpots(gfpSpots.cellIsGood==1,:);
cySpots = cySpots(cySpots.cellIsGood==1,:);
tmrSpots = tmrSpots(tmrSpots.cellIsGood==1,:);


%% Now let's compute distances and do colocalizations
% Note: not iterating over cells; assuming 1 "cell" per
% array
arrayIdx = unique(alexaSpots.arrayNum);

deltaXYalexacy = [];
deltaXYgfpcy   = [];
deltaXYtmrcy   = [];

for i = arrayIdx'
    tempAlexaSpots = table2array(alexaSpots(alexaSpots.arrayNum == i,{'xCenter','yCenter'}));
    tempGfpSpots = table2array(gfpSpots(gfpSpots.arrayNum == i,{'xCenter','yCenter'}));
    tempTmrSpots = table2array(tmrSpots(tmrSpots.arrayNum == i,{'xCenter','yCenter'}));
    tempCySpots = table2array(cySpots(cySpots.arrayNum == i,{'xCenter','yCenter'}));
    
    % Note that these deltas may have a few errors for various reasons, but
    % it's pretty much fine to just take the median.
    currDeltaXYalexacy = shiftCorrectCodes.getDeltaXY(tempAlexaSpots,tempCySpots);
    currDeltaXYgfpcy   = shiftCorrectCodes.getDeltaXY(tempGfpSpots,tempCySpots);
    currDeltaXYtmrcy   = shiftCorrectCodes.getDeltaXY(tempTmrSpots,tempCySpots);
    
    currDeltaXYalexacy(:,3) = i; % Add a column with the array number
    currDeltaXYgfpcy(:,3)   = i; % Add a column with the array number
    currDeltaXYtmrcy(:,3)   = i; % Add a column with the array number
    
    deltaXYalexacy = [deltaXYalexacy; currDeltaXYalexacy];
    deltaXYgfpcy   = [deltaXYgfpcy;   currDeltaXYgfpcy  ];
    deltaXYtmrcy   = [deltaXYtmrcy;   currDeltaXYtmrcy  ];
end

%% Here are the median shifts:

medPath1alexacy = median(deltaXYalexacy);
medPath1gfpcy  = median(deltaXYgfpcy);
medPath1tmrcy   = median(deltaXYtmrcy);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now, do folder 2
cd(beadPath2);

%% Pull out spot positions
alexaSpots = shiftCorrectCodes.getAllSpotPositions('alexa');
gfpSpots = shiftCorrectCodes.getAllSpotPositions('gfp');
cySpots = shiftCorrectCodes.getAllSpotPositions('cy');
tmrSpots = shiftCorrectCodes.getAllSpotPositions('tmr');

alexaSpots = alexaSpots(alexaSpots.cellIsGood==1,:);
gfpSpots = gfpSpots(gfpSpots.cellIsGood==1,:);
cySpots = cySpots(cySpots.cellIsGood==1,:);
tmrSpots = tmrSpots(tmrSpots.cellIsGood==1,:);


%% Now let's compute distances and do colocalizations
% Note: not iterating over cells; assuming 1 "cell" per
% array
arrayIdx = unique(alexaSpots.arrayNum);

deltaXYalexacy = [];
deltaXYgfpcy   = [];
deltaXYtmrcy   = [];

for i = arrayIdx'
    tempAlexaSpots = table2array(alexaSpots(alexaSpots.arrayNum == i,{'xCenter','yCenter'}));
    tempGfpSpots = table2array(gfpSpots(gfpSpots.arrayNum == i,{'xCenter','yCenter'}));
    tempTmrSpots = table2array(tmrSpots(tmrSpots.arrayNum == i,{'xCenter','yCenter'}));
    tempCySpots = table2array(cySpots(cySpots.arrayNum == i,{'xCenter','yCenter'}));
    
    % Note that these deltas may have a few errors for various reasons, but
    % it's pretty much fine to just take the median.
    currDeltaXYalexacy = shiftCorrectCodes.getDeltaXY(tempAlexaSpots,tempCySpots);
    currDeltaXYgfpcy   = shiftCorrectCodes.getDeltaXY(tempGfpSpots,tempCySpots);
    currDeltaXYtmrcy   = shiftCorrectCodes.getDeltaXY(tempTmrSpots,tempCySpots);
    
    currDeltaXYalexacy(:,3) = i; % Add a column with the array number
    currDeltaXYgfpcy(:,3)   = i; % Add a column with the array number
    currDeltaXYtmrcy(:,3)   = i; % Add a column with the array number
    
    deltaXYalexacy = [deltaXYalexacy; currDeltaXYalexacy];
    deltaXYgfpcy   = [deltaXYgfpcy;   currDeltaXYgfpcy  ];
    deltaXYtmrcy   = [deltaXYtmrcy;   currDeltaXYtmrcy  ];
end

%% This part is to split up by field of view to hunt for systematic differences between fields of view
% Not really used, but there in case you want to check at some point.
% 
% tbalexacy = array2table(deltaXYalexacy,'VariableNames',{'x','y','arrayNum'});
% tbgfpcy = array2table(deltaXYgfpcy,'VariableNames',{'x','y','arrayNum'});
% tbtmrcy = array2table(deltaXYtmrcy,'VariableNames',{'x','y','arrayNum'});
% 
% G = findgroups(tbalexacy.arrayNum);
% medsAlexa = splitapply(@median,table2array(tbalexacy),G); % Why does this not work as a table?!
% 
% G = findgroups(tbgfpcy.arrayNum);
% medsGfp = splitapply(@median,table2array(tbgfpcy),G);
% 
% G = findgroups(tbtmrcy.arrayNum);
% medsTmr = splitapply(@median,table2array(tbtmrcy),G);

%% Here are the median shifts:

medPath2alexacy = median(deltaXYalexacy);
medPath2gfpcy  = median(deltaXYgfpcy);
medPath2tmrcy   = median(deltaXYtmrcy);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now done, calculate means of the medians.
dXYalexacy = mean([medPath1alexacy;medPath2alexacy])';
dXYgfpcy = mean([medPath1gfpcy;medPath2gfpcy])';
dXYtmrcy = mean([medPath1tmrcy;medPath2tmrcy])';

%% Write the output:

shiftTable = table(dXYalexacy,dXYgfpcy,dXYtmrcy);
shiftTable.Properties.VariableNames = {'alexacy','gfpcy','tmrcy'};
shiftTable.Properties.RowNames = {'x','y','z'};
shiftTable('z',:) = []; % Remove z, since we don't really use it

writetable(shiftTable,outFile,'WriteRowNames',true);
