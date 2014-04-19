dentist.tests.cleanupForTests;
myDir = '~/code/dentist_test/3by3';
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(myDir);
imageDirectoryReader.implementGridLayout(3,3,'down','right','nosnake');
numPixelOverlap = 103;
imageProvider = dentist.utils.ImageProvider(imageDirectoryReader, numPixelOverlap);
viewport = dentist.utils.TileAwareImageViewport(imageProvider);

channelHolder = dentist.utils.ChannelHolder('dapi');

figH = figure(1);
set(figH, 'Colormap', gray(256))
subplot(1,2,1)
ax1 = gca;
img = viewport.getCroppedImage(imageProvider, channelHolder.getChannelName());
imshow(scale(img), 'InitialMagnification', 'fit')


viewport = viewport.scaleSize(0.4);
viewport.drawBoundaryRectangle('EdgeColor', 'b', 'Parent', ax1);

ax2 = subplot(1,2,2);
axis ij;
set(ax2, 'DataAspectRatio', [1 1 1])

mockThumbnailImages = dentist.utils.ChannelArray(imageProvider.availableChannels);

mockThumbnailImages = mockThumbnailImages.setByChannelName(rand(20,20),'dapi');
mockThumbnailImages = mockThumbnailImages.setByChannelName(rand(20,20),'tmr');

viewportHolder = dentist.utils.ViewportHolder(viewport);

x = dentist.utils.ThumbnailDisplayer(ax2, mockThumbnailImages, channelHolder, ...
    viewportHolder, 'EdgeColor', 'green');

x.draw()

% Try to set channel and redraw

viewport = viewportHolder.getViewport();
viewport = viewport.tryToCenterAtXPosition(2000);
viewport.drawBoundaryRectangle('Parent',ax1,'EdgeColor','r');
viewportHolder.setViewport(viewport);

x.draw()

