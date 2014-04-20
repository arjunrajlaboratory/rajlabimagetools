%% getCroppedImage
dentist.tests.cleanupForTests;
testDataDir = dentist.tests.data.locator();
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(testDataDir);
imageDirectoryReader.implementGridLayout(2,2,'down','right','nosnake');
numPixelOverlap = 103;
imageProvider = dentist.utils.ImageProvider(imageDirectoryReader, numPixelOverlap);

viewport = dentist.utils.TileAwareImageViewport(imageProvider);

img = viewport.getCroppedImage(imageProvider, 'dapi');
figure(1);
ax1 = subplot(2,2,1);
imshow(imadjust(img), 'InitialMagnification', 'fit')

viewport.drawBoundaryRectangle('EdgeColor', 'r', 'Parent', ax1);
viewport = viewport.scaleSize(0.6);
viewport.drawBoundaryRectangle('EdgeColor', 'b', 'Parent', ax1);

ax2 = subplot(2,2,2);
img = viewport.getCroppedImage(imageProvider, 'dapi');
imshow(imadjust(img), 'InitialMagnification', 'fit')

viewport = viewport.tryToCenterAtXPosition(viewport.imageWidth);
viewport = viewport.tryToCenterAtYPosition(viewport.imageHeight);
viewport.drawBoundaryRectangle('EdgeColor', 'w', 'Parent', ax1);

ax3 = subplot(2,2,3);
img = viewport.getCroppedImage(imageProvider, 'dapi');
imshow(imadjust(img), 'InitialMagnification', 'fit')

viewport = viewport.scaleSize(0.6);
viewport.drawBoundaryRectangle('EdgeColor', 'g', 'Parent', ax1);

ax4 = subplot(2,2,4);
img = viewport.getCroppedImage(imageProvider, 'dapi');
imshow(imadjust(img), 'InitialMagnification', 'fit')
