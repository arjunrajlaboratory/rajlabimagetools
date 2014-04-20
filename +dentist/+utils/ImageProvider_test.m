dentist.tests.cleanupForTests;
testDataDir = dentist.tests.data.locator();
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(testDataDir);
imageDirectoryReader.implementGridLayout(2,2,'down','right','nosnake');

pixelOverlap = 103;

Nrows = 2;
Ncols = 2;

myProvider = dentist.utils.ImageProvider(imageDirectoryReader, pixelOverlap);

figure(1);

tile = dentist.utils.TilePosition(Nrows, Ncols, 1, 1);
myProvider.goToTile(tile);
subplot(2,2,1)
img = myProvider.getImageFromChannel('tmr');
imshow(imadjust(img),'InitialMagnification','fit');
title(sprintf('height: %d width: %d', size(img,1), size(img,2)))

tile = tile.goToEdge('up');
tile = tile.goToEdge('right');
myProvider.goToTile(tile);
subplot(2,2,2)
img = myProvider.getImageFromChannel('tmr');
imshow(imadjust(img),'InitialMagnification','fit');
title(sprintf('height: %d width: %d', size(img,1), size(img,2)))

tile = tile.goToEdge('down');
tile = tile.goToEdge('left');
myProvider.goToTile(tile);
subplot(2,2,3)
img = myProvider.getImageFromChannel('tmr');
imshow(imadjust(img),'InitialMagnification','fit');
title(sprintf('height: %d width: %d', size(img,1), size(img,2)))

tile = tile.goToEdge('down');
tile = tile.goToEdge('right');
myProvider.goToTile(tile);
subplot(2,2,4)
img = myProvider.getImageFromChannel('tmr');
imshow(imadjust(img),'InitialMagnification','fit');
title(sprintf('height: %d width: %d', size(img,1), size(img,2)))

%% Extended dapi image
figure(2);

tile = dentist.utils.TilePosition(Nrows, Ncols, 1, 1);
myProvider.goToTile(tile);
subplot(2,2,1)
img = myProvider.getExtendedDapiImage();
imshow(imadjust(img),'InitialMagnification','fit');
title(sprintf('height: %d width: %d', size(img,1), size(img,2)))

tile = tile.goToEdge('up');
tile = tile.goToEdge('right');
myProvider.goToTile(tile);
subplot(2,2,2)
img = myProvider.getExtendedDapiImage();
imshow(imadjust(img),'InitialMagnification','fit');
title(sprintf('height: %d width: %d', size(img,1), size(img,2)))

tile = tile.goToEdge('down');
tile = tile.goToEdge('left');
myProvider.goToTile(tile);
subplot(2,2,3)
img = myProvider.getExtendedDapiImage();
imshow(imadjust(img),'InitialMagnification','fit');
title(sprintf('height: %d width: %d', size(img,1), size(img,2)))

tile = tile.goToEdge('down');
tile = tile.goToEdge('right');
myProvider.goToTile(tile);
subplot(2,2,4)
img = myProvider.getExtendedDapiImage();
imshow(imadjust(img),'InitialMagnification','fit');
title(sprintf('height: %d width: %d', size(img,1), size(img,2)))
