improc2.tests.cleanupForTests;

warning('off', 'MATLAB:Figure:SetPosition');

set(0,'DefaultFigureWindowStyle','docked')
%set(0,'DefaultFigureWindowStyle','normal')

collection = improc2.tests.data.collectionOfUnProcessedDAGObjects();

dataAdder = improc2.processing.DataAdder(collection);
dataAdder.view();
%%
dataAdder.addDataToObject(improc2.nodeProcs.aTrousRegionalMaxProcessedData(),...
    'cy', 'cy:Spots')
dataAdder.view();
%%
dataAdder.addDataToObject(improc2.nodeProcs.aTrousRegionalMaxProcessedData(), 'alexa', 'alexa:Spots')
dataAdder.addDataToObject(improc2.nodeProcs.aTrousRegionalMaxProcessedData(), 'tmr', 'tmr:Spots')
dataAdder.addDataToObject(improc2.nodeProcs.TransProcessedData(), 'trans', 'transProc')
dataAdder.addDataToObject(improc2.nodeProcs.DapiProcessedData(), 'dapi', 'dapiProc')
dataAdder.view();
%%
dataAdder.repeatForAllObjectsAndQuit();

%%
improc2.processing.updateAll(collection);




%%  Add volume

dataAdder = improc2.processing.DataAdder(collection);
dataAdder.view()
%%
planeSpacing = 0.35;
dataAdder.addDataToObject(improc2.nodeProcs.VolumeFromSpotsCloud(planeSpacing), ...
    {'imageObject', 'dapiProc', 'cy:Spots'}, 'cy:Volume')

%%
dataAdder.view()
%%
dataAdder.repeatForAllObjectsAndQuit();
%%
improc2.processing.updateAll(collection);


%%  Add Fitted Spots

dataAdder = improc2.processing.DataAdder(collection);
dataAdder.view();
%%
dataAdder.addDataToObject(improc2.nodeProcs.TwoStageSpotFitProcessedData, 'tmr', 'tmr:Fitted')
dataAdder.view();
%%
dataAdder.repeatForAllObjectsAndQuit();

improc2.processing.updateAll(collection);
%%

tools = improc2.launchImageObjectBrowsingTools(collection);
tools.objectHandle.view();

%%
improc2.launchThresholdGUI(collection);

%%
tools.refresh();
tools.navigator.tryToGoToArray(1);
tools.navigator.tryToGoToObj(1);
tools.objectHandle.view()
%%

tools.navigator.tryToGoToObj(2);
tools.objectHandle.view()
%%

improc2.processing.updateAll(collection);
%%
tools.refresh();
tools.navigator.tryToGoToArray(1);
tools.navigator.tryToGoToObj(1);
tools.objectHandle.view()
tools.navigator.tryToGoToObj(2);
tools.objectHandle.view()

%% getting:

cySpots = tools.objectHandle.getData('cy');
volProc = tools.objectHandle.getData(...
    'imageObject', 'improc2.nodeProcs.VolumeFromSpotsCloud');


%% add threshold QC




dataAdder = improc2.processing.DataAdder(collection);
dataAdder.view();
%%
dataAdder.addDataToObject(improc2.nodeProcs.ThresholdQCData(), 'cy:Spots', 'cy:ThreshQC')
dataAdder.addDataToObject(improc2.nodeProcs.ThresholdQCData(), 'tmr:Spots', 'tmr:ThreshQC')
dataAdder.addDataToObject(improc2.nodeProcs.ThresholdQCData(), 'alexa:Spots', 'alexa:ThreshQC')
dataAdder.view();
%%
dataAdder.repeatForAllObjectsAndQuit();

%%
improc2.processing.updateAll(collection)
