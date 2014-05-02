improc2.tests.cleanupForTests;

warning('off', 'MATLAB:Figure:SetPosition');

set(0,'DefaultFigureWindowStyle','docked')
%set(0,'DefaultFigureWindowStyle','normal')

collection = improc2.tests.data.collectionOfUnProcessedDAGObjects();

dataAdder = improc2.processing.DataAdder(collection);
dataAdder.view();
%%
dataAdder.addDataToObject(improc2.nodeProcs.aTrousRegionalMaxProcessedData(), 'cy', 'cy:Spots')
dataAdder.view();
%%
dataAdder.addDataToObject(improc2.nodeProcs.aTrousRegionalMaxProcessedData(), 'alexa', 'alexa:Spots')
dataAdder.addDataToObject(improc2.nodeProcs.aTrousRegionalMaxProcessedData(), 'tmr', 'tmr:Spots')
dataAdder.addDataToObject(improc2.nodeProcs.TransProcessedData(), 'trans', 'transProc')
dataAdder.addDataToObject(improc2.nodeProcs.DapiProcessedData(), 'dapi', 'dapiProc')
dataAdder.view();
%%
dataAdder.repeatForAllObjectsAndQuit();






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
dataAdder.addDataToObject(improc2.nodeProcs.TwoStageSpotFitProcessedData, 'cy', 'cy:Fitted')
dataAdder.addDataToObject(improc2.nodeProcs.TwoStageSpotFitProcessedData, 'tmr', 'tmr:Fitted')
dataAdder.view();
%%
dataAdder.repeatForAllObjectsAndQuit();

improc2.processing.updateAll(collection);
%%





%% add threshold QC

dataAdder = improc2.processing.DataAdder(collection);
dataAdder.view();
%%
dataAdder.addDataToObject(improc2.nodeProcs.ThresholdQCData(), 'cy', 'cy:ThreshQC')
dataAdder.addDataToObject(improc2.nodeProcs.ThresholdQCData(), 'tmr', 'tmr:ThreshQC')
dataAdder.addDataToObject(improc2.nodeProcs.ThresholdQCData(), 'alexa', 'alexa:ThreshQC')
dataAdder.view();
%%
dataAdder.repeatForAllObjectsAndQuit();

%%
improc2.processing.updateAll(collection)






tools = improc2.launchImageObjectBrowsingTools(collection);
tools.objectHandle.view()