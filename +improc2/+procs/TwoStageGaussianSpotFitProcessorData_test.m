improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();
channelName = 'cy';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);
imageProvider.loadImage(objH, channelName);
croppedImg = imageProvider.croppedimg;
objmask = objH.getCroppedMask();

unprocessedData = improc2.procs.aTrousRegionalMaxProcData();
firstProcessorData = run(unprocessedData, croppedImg, objmask);

x = improc2.procs.TwoStageGaussianSpotFitProcessorData();
xProcessed = run(x, firstProcessorData, croppedImg, objmask);

assert(length(xProcessed.getFittedSpots()) == firstProcessorData.getNumSpots())
assert(length(xProcessed.getFittedBackgLevels()) == firstProcessorData.getNumSpots())

fittedSpotsImg = zeros(size(croppedImg));

fittedSpotsImg = improc2.tests.addGaussianSpotToImage(...
    fittedSpotsImg, xProcessed.getFittedSpots);
    
subplot(1,2,1)
imshow(scale(max(croppedImg, [], 3)), 'InitialMagnification', 'fit')
title('original, unfiltered')
subplot(1,2,2)
imshow(scale(max(fittedSpotsImg, [], 3)), 'InitialMagnification', 'fit')
title('fitted gaussian spots')
