improc2.tests.cleanupForTests;

[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();

channelName = 'trans';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);

channelStackContainer = improc2.dataNodes.ChannelStackContainer();
channelStackContainer.croppedImage = imageProvider.getImage(objH, channelName);
channelStackContainer.croppedMask = objH.getCroppedMask();

x = improc2.nodeProcs.TransProcessedData();

assert(isa(x,'improc2.interfaces.ProcessedData'))

xProcessed = run(x, channelStackContainer);

assert(isempty(getImage(x)))
assert(~isempty(getImage(xProcessed)))
