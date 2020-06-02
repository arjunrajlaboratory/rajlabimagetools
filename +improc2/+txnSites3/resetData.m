% reset data

dataAdder = improc2.processing.DataAdder();

unprocessedFittedData = improc2.nodeProcs.TwoStageSpotFitProcessedData();

dataAdder.addDataToObject(unprocessedFittedData, 'alexa', 'alexa:Fitted')
dataAdder.addDataToObject(unprocessedFittedData, 'cy', 'cy:Fitted')
% dataAdder.addDataToObject(unprocessedFittedData, 'nir', 'nir:Fitted')
% dataAdder.addDataToObject(unprocessedFittedData, 'gfp', 'gfp:Fitted')
dataAdder.addDataToObject(unprocessedFittedData, 'tmr', 'tmr:Fitted')

dataAdder.repeatForAllObjectsAndQuit();
improc2.processing.updateAll

%%
tools = improc2.launchImageObjectBrowsingTools;
addClickedSpotsData(tools.objectHandle)

%%
channels = {'cy','tmr','alexa'};
nodeName = 'alexaFirst';
addClickedSpotsData(tools.objectHandle, 'channels', channels, 'nodeName', nodeName)
%%
launchGUI2('channels', channels, 'nodeName', nodeName)