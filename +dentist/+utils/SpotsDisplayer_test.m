dentist.tests.cleanupForTests;

[viewport, mockSource] = dentist.tests.setupForSpotsDisplayer();

channelHolder = dentist.utils.ChannelHolder('cy');
viewportHolder = dentist.utils.ViewportHolder(viewport);

img = zeros(10,10);

subplotrows = 2; subplotcols = 3;
figure(1); ax1 = subplot(subplotrows, subplotcols, 1);
imshow(img, 'InitialMagnification', 'fit')

viewport.drawBoundaryRectangle('EdgeColor', 'g');

centroids = mockSource.getCentroids();
spots = mockSource.getSpots('cy');
hold on
plot(centroids.xPositions, centroids.yPositions, '.r')
plot(spots.xPositions, spots.yPositions, 'ob')
hold off

%
ax2 = subplot(subplotrows, subplotcols, 2);

imshow(img, 'InitialMagnification', 'fit')

viewport.drawBoundaryRectangle('EdgeColor', 'g');

x = dentist.utils.SpotsDisplayer(ax2, mockSource, channelHolder, viewportHolder);
x.draw();
title('draw')

%%
ax3 = subplot(subplotrows, subplotcols, 3);

imshow(img, 'InitialMagnification', 'fit')

viewport.drawBoundaryRectangle('EdgeColor', 'g');

x = dentist.utils.SpotsDisplayer(ax3, mockSource, channelHolder, viewportHolder);
x.draw();
viewport = viewportHolder.getViewport();
newViewport = viewport.tryToCenterAtXPosition(5);
newViewport = newViewport.tryToCenterAtYPosition(8);
newViewport.drawBoundaryRectangle('EdgeColor', 'b');
viewportHolder.setViewport(newViewport);

x.draw();
title('draw again deletes old')

viewportHolder.setViewport(viewport);
%
ax4 = subplot(subplotrows, subplotcols, 4);

imageH = imshow(img, 'InitialMagnification', 'fit');

rectangleH = viewport.drawBoundaryRectangle('EdgeColor', 'g');

x = dentist.utils.SpotsDisplayer(ax4, mockSource, channelHolder, viewportHolder);
x.draw();
title('deactivate deletes all')
x.deactivate();

% deactivate test
expectedHandlesLeft = [imageH, rectangleH];
assert(length(get(gca,'Children')) == length(expectedHandlesLeft));
assert(all(ismember(expectedHandlesLeft, get(gca,'Children'))))

%
ax5 = subplot(subplotrows, subplotcols, 5);

imageH = imshow(img, 'InitialMagnification', 'fit');

rectangleH = viewport.drawBoundaryRectangle('EdgeColor', 'g');

x = dentist.utils.SpotsDisplayer(ax5, mockSource, channelHolder, viewportHolder);
channelHolder.setChannelName('tmr')
x.draw();

title('another channel')


%% what if there are no spots?

figH = figure(2);
axH = axes('Parent', figH);

centroids = dentist.utils.Centroids( [1,2], [1,2]);
spots = dentist.utils.ChannelArray({'cy'});
spots = spots.setByChannelName( dentist.utils.Spots([], [], []), 'cy');
assignments = dentist.utils.ChannelArray({'cy'});
assignments = assignments.setByChannelName([], 'cy');

nospotsSource = dentist.tests.MockSpotsAndCentroidsSource(centroids, ...
        spots, assignments);
    
channelHolder.setChannelName('cy')
viewportHolder = dentist.utils.ViewportHolder(dentist.utils.ImageViewport(4,4));
x = dentist.utils.SpotsDisplayer(axH, nospotsSource, channelHolder, viewportHolder);
x.draw()
title('should have no spots')
