improc2.tests.cleanupForTests
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();
channelName = 'cy';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);
imageProvider.loadImage(objH, channelName);
croppedImg = imageProvider.croppedimg;
objmask = objH.getCroppedMask();


x = improc2.aTrousImageFilter;
imout = x.applyFilter(croppedImg);
figure(1);clf;
imshow(scale(croppedImg(:, :, sliceWithSpots))); %original slice
figure(2);clf;
imshow(scale(imout(:, :, sliceWithSpots))); % enhances spots

x = improc2.aTrousImageFilter(struct('numLevels',5));
imout2 = x.applyFilter(croppedImg);
figure(3);clf;
imshow(scale(imout2(:, :, sliceWithSpots))); % includes more background
