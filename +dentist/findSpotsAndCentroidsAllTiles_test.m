dentist.tests.cleanupForTests;
testDataDir = dentist.tests.data.locator();
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(testDataDir);
imageDirectoryReader.implementGridLayout(2,2,'down','right','nosnake');
numPixelOverlap = 103;
imageProvider = dentist.utils.ImageProvider(imageDirectoryReader, numPixelOverlap);

verboseFlag = false;
[spots, centroids, frequencyTableArray] = dentist.findSpotsAndCentroidsAllTiles(imageProvider, verboseFlag);


channelHolder = dentist.utils.ChannelHolder('dapi');
figH = figure(); axH = axes('Parent', figH);
set(figH, 'Colormap', gray(256))
viewport = dentist.utils.TileAwareImageViewport(imageProvider);
viewportHolder = dentist.utils.ViewportHolder(viewport);
tileDisplayer = dentist.utils.TiledImageDisplayer(axH, imageProvider, channelHolder, viewportHolder);
tileDisplayer.draw();

hold on;
tmrSpots = spots.getByChannelName('tmr');
plot(tmrSpots.xPositions, tmrSpots.yPositions,'.b');
plot(centroids.xPositions, centroids.yPositions, 'o','Color','r');

