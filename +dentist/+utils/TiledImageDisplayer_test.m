dentist.tests.cleanupForTests;
myDir = '~/code/dentist_test/2by2';
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(myDir);
imageDirectoryReader.implementGridLayout(2,2,'down','right','nosnake');
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


viewport = viewport.scaleSize(0.6);
viewport.drawBoundaryRectangle('EdgeColor', 'b', 'Parent', ax1);

viewportHolder = dentist.utils.ViewportHolder(viewport);

ax2 = subplot(1,2,2);
axis ij;
set(ax2, 'DataAspectRatio', [1 1 1])

x = dentist.utils.TiledImageDisplayer(ax2, imageProvider, channelHolder, viewportHolder);

x.draw()

% Try to set channel and redraw

%%
viewport = viewportHolder.getViewport();
viewport = viewport.setWidth(638);
viewport = viewport.setHeight(638);
viewport = viewport.tryToPlaceULCornerAtXPosition(1307);
viewport = viewport.tryToPlaceULCornerAtYPosition(362);
viewportHolder.setViewport(viewport);

x.draw()
viewport.drawBoundaryRectangle('EdgeColor', 'g', 'Parent', ax1);



