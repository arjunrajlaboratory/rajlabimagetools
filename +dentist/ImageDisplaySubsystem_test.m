dentist.tests.cleanupForTests;
testDataDir = dentist.tests.data.locator();
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(testDataDir);
imageDirectoryReader.implementGridLayout(2,2,'down','right','nosnake');
numPixelOverlap = 103;
imageProvider = dentist.utils.ImageProvider(imageDirectoryReader, numPixelOverlap);


viewport = dentist.utils.TileAwareImageViewport(imageProvider);
viewportHolder = dentist.utils.ViewportHolder(viewport);

channelHolder = dentist.utils.ChannelHolder('dapi');

figH = figure(1);
set(figH, 'Colormap', gray(256))
subplot(1,3,1)
ax1 = gca;
img = viewport.getCroppedImage(imageProvider, channelHolder.getChannelName());
imshow(scale(img), 'InitialMagnification', 'fit')


ax2 = subplot(1,3,2);
axis ij;
set(ax2, 'DataAspectRatio', [1 1 1])

tileDisplayer = dentist.utils.TiledImageDisplayer(ax2, imageProvider, ...
    channelHolder, viewportHolder);


ax3 = subplot(1,3,3);
axis ij;
set(ax3, 'DataAspectRatio', [1 1 1])

mockThumbnailImages = dentist.utils.ChannelArray(imageProvider.availableChannels);
mockThumbnailImages = mockThumbnailImages.setByChannelName(rand(10,10),'dapi');
mockThumbnailImages = mockThumbnailImages.setByChannelName(rand(10,10),'tmr');

thumbnailDisplayer = dentist.utils.ThumbnailDisplayer(ax3, ...
    mockThumbnailImages, channelHolder, viewportHolder, 'EdgeColor', 'b');

%should draw;
x = dentist.ImageDisplaySubsystem(viewportHolder, tileDisplayer, thumbnailDisplayer);
x.draw();


% test of attaching dependencies

a = dentist.tests.MockDrawCountingDisplayer();
b = dentist.tests.MockDrawCountingDisplayer();

x.addActionAfterViewportUpdate(a, @draw)
x.addActionAfterViewportUpdate(b, @draw)

assert(a.timesDrawn == 0)
assert(b.timesDrawn == 0)

viewport = x.getViewport();
viewport = viewport.scaleSize(0.4);
viewport.drawBoundaryRectangle('EdgeColor', 'b', 'Parent', ax1);
x.setViewport(viewport);

assert(a.timesDrawn == 1)
assert(b.timesDrawn == 1)

title(ax1, 'nothing happens here')
title(ax2, 'try to pan')
title(ax3, 'try to pan')
imagePanner = dentist.utils.ImagePanningMouseInterpreter(x); 
imagePanner.wireToFigureAndAxes(figH, ax2);

thumbnailPanner = dentist.utils.ThumbnailPanningMouseInterpreter(x);
thumbnailPanner.wireToFigureAndAxes(figH, ax3);




