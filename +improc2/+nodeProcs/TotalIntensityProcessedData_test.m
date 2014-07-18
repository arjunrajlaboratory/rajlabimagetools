improc2.tests.cleanupForTests;

[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();
channelName = 'dapi';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);

channelStackContainer = improc2.dataNodes.ChannelStackContainer();
channelStackContainer.croppedImage = imageProvider.getImage(objH, channelName);
channelStackContainer.croppedMask = objH.getCroppedMask();

x = improc2.nodeProcs.TotalIntensityProcessedData();

assert(isa(x,'improc2.interfaces.ProcessedData'))

assert(isempty(x.summedIntensity))

x = run(x, channelStackContainer);

assert(~ isempty(x.summedIntensity))