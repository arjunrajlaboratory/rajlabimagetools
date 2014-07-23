improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();
channelName = 'cy';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);

channelStackContainer = improc2.dataNodes.ChannelStackContainer();
channelStackContainer.croppedImage = imageProvider.getImage(objH, channelName);
channelStackContainer.croppedMask = objH.getCroppedMask();

unprocessedData = improc2.nodeProcs.aTrousRegionalMaxProcessedData();
firstProcessorData = run(unprocessedData, channelStackContainer);

x = improc2.nodeProcs.TwoStageSpotFitProcessedData();
xProcessed = run(x, firstProcessorData, channelStackContainer);


%Test no spots boundary case
firstProcessorData.threshold = 1000000;
xProcessed2 = run(x, firstProcessorData, channelStackContainer);



assert(length(xProcessed.getFittedSpots()) == firstProcessorData.getNumSpots())
assert(length(xProcessed.getFittedBackgLevels()) == firstProcessorData.getNumSpots())

fittedSpotsImg = zeros(size(channelStackContainer.croppedImage));

fittedSpotsImg = improc2.tests.addGaussianSpotToImage(...
    fittedSpotsImg, xProcessed.getFittedSpots);
    
subplot(1,2,1)
imshow(scale(max(channelStackContainer.croppedImage, [], 3)), 'InitialMagnification', 'fit')
title('original, unfiltered')
subplot(1,2,2)
imshow(scale(max(fittedSpotsImg, [], 3)), 'InitialMagnification', 'fit')
title('fitted gaussian spots')
