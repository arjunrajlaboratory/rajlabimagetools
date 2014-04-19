improc2.tests.cleanupForTests;

[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();
channelName = 'dapi';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);
imageProvider.loadImage(objH, channelName);
croppedImg = imageProvider.croppedimg;
objmask = objH.getCroppedMask();

x = improc2.procs.DapiProcData();
xProcessed = run(x, croppedImg, objmask);
figure(1);ax=axes();
xProcessed.plotImage(ax);
