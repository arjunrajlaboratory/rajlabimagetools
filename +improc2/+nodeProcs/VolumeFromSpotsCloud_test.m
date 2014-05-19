improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfProcessedDAGObjects();
tools = improc2.launchImageObjectBrowsingTools(collection);


mockMaskContainer = struct();
mockMaskContainer.mask = tools.objectHandle.getCroppedMask();

dapiProcData = tools.objectHandle.getData('dapi');

cySpotsData = tools.objectHandle.getData('cy');

planeSpacing = 0.35;
x = improc2.nodeProcs.VolumeFromSpotsCloud(planeSpacing);
xProcessed = run(x, mockMaskContainer, dapiProcData, cySpotsData);
