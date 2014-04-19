improc2.tests.cleanupForTests;

[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();

channelName = 'trans';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);
imageProvider.loadImage(objH, channelName);
croppedImg = imageProvider.croppedimg;
objmask = objH.getCroppedMask();

x = improc2.procs.TransProcData();

assert(~x.isProcessed)
xProcessed = run(x, croppedImg, objmask);
assert(xProcessed.isProcessed)
assert(all(size(xProcessed.getImage()) == size(objmask)))
xProcessed.plotImage();
