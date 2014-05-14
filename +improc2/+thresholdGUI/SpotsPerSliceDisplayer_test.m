improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfProcessedDAGObjects();
browsingTools = improc2.launchImageObjectBrowsingTools(collection);

figH = figure(1); clf; axH = axes('Parent', figH); axis('xy');

procData = browsingTools.objectHandle.getProcessorData('cy');
procData.excludedSlices =[1, 2];
procDataHolder = improc2.tests.MockProcessorDataHolder(procData);

displayer = improc2.thresholdGUI.SpotsPerSliceDisplayer(axH, procDataHolder);

displayer.draw();
