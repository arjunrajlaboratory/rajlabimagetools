improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfProcessedDAGObjects();
tools = improc2.launchImageObjectBrowsingTools(collection);


mockMaskContainer = struct();
mockMaskContainer.mask = tools.objectHandle.getCroppedMask();

dapiProcData = tools.objectHandle.getProcessorData('dapi');
%fakeNoNuclearMaskContainer = struct();
%fakeNoNuclearMaskContainer.mask = false(size(mockMaskContainer.mask));

cySpotsData = tools.objectHandle.getProcessorData('cy');

planeSpacing = 0.35;
x = improc2.nodeProcs.VolumeFromSpotsCloud(planeSpacing);
xProcessed = run(x, mockMaskContainer, dapiProcData, cySpotsData);