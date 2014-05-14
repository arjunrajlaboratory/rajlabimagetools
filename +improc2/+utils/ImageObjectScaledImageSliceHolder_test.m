improc2.tests.cleanupForTests;

inMemoryCollection = improc2.tests.data.collectionOfProcessedDAGObjects();
browsingTools = improc2.launchImageObjectBrowsingTools(inMemoryCollection);
objectHandle = browsingTools.objectHandle;

channelSwitcher = dentist.utils.ChannelSwitchCoordinator(objectHandle.channelNames);

zSlicer = improc2.utils.ZSlicer();
zSlicer.setSliceToTake(1);

croppedStkProvider = improc2.ImageObjectCroppedStkProvider();

alexaCroppedImage = croppedStkProvider.getImage(objectHandle, 'alexa');
alexaMaxAndMin = [min(alexaCroppedImage(:)), max(alexaCroppedImage(:))];
alexaScaledImage = improc2.utils.scale(alexaCroppedImage);


x = improc2.utils.ImageObjectScaledImageSliceHolder(...
    objectHandle, channelSwitcher, croppedStkProvider, zSlicer);

[img, maxAndMin] = x.getImage();
assert(all(all(img == alexaScaledImage(:,:,1))))
assert(all(maxAndMin == alexaMaxAndMin))

zSlicer.setSliceToTake(3);
[img, maxAndMin] = x.getImage();
assert(all(all(img == alexaScaledImage(:,:,3))))
assert(all(maxAndMin == alexaMaxAndMin))

channelSwitcher.setChannelName('tmr')

tmrCroppedImage = croppedStkProvider.getImage(objectHandle, 'tmr');
tmrMaxAndMin = [min(tmrCroppedImage(:)), max(tmrCroppedImage(:))];
tmrScaledImage = improc2.utils.scale(tmrCroppedImage);

[img, maxAndMin] = x.getImage();
assert(all(all(img == tmrScaledImage(:,:,3))))
assert(all(maxAndMin == tmrMaxAndMin))
