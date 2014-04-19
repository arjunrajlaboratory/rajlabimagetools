dentist.tests.cleanupForTests;

[viewport, mockSource] = dentist.tests.setupForCentroidsAndNumSpots();
img = zeros(viewport.imageWidth, viewport.imageHeight);
centroids = mockSource.getCentroids();
figure(1); 
subplotrows = 2;
subplotcols = 3;

viewportHolder = dentist.utils.ViewportHolder(viewport);
channelHolder = dentist.utils.ChannelHolder('cy');


%%
ax1 = subplot(subplotrows,subplotcols,1); 
imshow(img, 'InitialMagnification', 'fit');
viewport.drawBoundaryRectangle('EdgeColor', 'g');

hold on
plot(centroids.xPositions, centroids.yPositions, '.r')
hold off


parametersHolder = dentist.utils.CentroidsNumSpotsParametersHolder();
x = dentist.utils.CentroidsNumSpotsTextDisplayer(ax1, mockSource, channelHolder, ...
    parametersHolder, viewportHolder); 
x.draw();
title('Displays in viewport')


%%
ax2 = subplot(subplotrows, subplotcols, 2);
imshow(img, 'InitialMagnification', 'fit');

hold on
plot(centroids.xPositions, centroids.yPositions, '.r')
hold off

parametersHolder = dentist.utils.CentroidsNumSpotsParametersHolder();
x = dentist.utils.CentroidsNumSpotsTextDisplayer(ax2, mockSource, channelHolder, ...
    parametersHolder, viewportHolder);
parametersHolder.set('FontSize', 20)
x.draw();
title('FontSize');

%%
ax3 = subplot(subplotrows, subplotcols, 3);
imshow(img, 'InitialMagnification', 'fit');

hold on
plot(centroids.xPositions, centroids.yPositions, '.r')
hold off

parametersHolder = dentist.utils.CentroidsNumSpotsParametersHolder();
x = dentist.utils.CentroidsNumSpotsTextDisplayer(ax3, mockSource, channelHolder, ...
    parametersHolder, viewportHolder);
parametersHolder.set('xOffset', -2, 'yOffset', 5)
x.draw();
title('xOffset & yOffset')


%%
ax4 = subplot(subplotrows, subplotcols, 4);
imshow(img, 'InitialMagnification', 'fit');

hold on
plot(centroids.xPositions, centroids.yPositions, '.r')

parametersHolder = dentist.utils.CentroidsNumSpotsParametersHolder();
x = dentist.utils.CentroidsNumSpotsTextDisplayer(ax4, mockSource, channelHolder, ...
    parametersHolder, viewportHolder);
x.draw();
x.deactivate();
title('Deactivate deletes all')
%%

ax5 = subplot(subplotrows, subplotcols, 5);
imshow(img, 'InitialMagnification', 'fit');

hold on
plot(centroids.xPositions, centroids.yPositions, '.r')
hold off

parametersHolder = dentist.utils.CentroidsNumSpotsParametersHolder();
x = dentist.utils.CentroidsNumSpotsTextDisplayer(ax5, mockSource, channelHolder, ...
    parametersHolder, viewportHolder);
viewport.drawBoundaryRectangle('EdgeColor', 'g');
x.draw();
otherViewport = viewport.tryToCenterAtXPosition(5);
otherViewport = otherViewport.tryToCenterAtYPosition(8);
otherViewport.drawBoundaryRectangle('EdgeColor', 'b');
viewportHolder.setViewport(otherViewport);
x.draw();
title('Draw deletes old')

%% 

ax6 = subplot(subplotrows, subplotcols, 6);
imshow(img, 'InitialMagnification', 'fit');

hold on
plot(centroids.xPositions, centroids.yPositions, '.r')
hold off

viewportHolder.setViewport(viewport)

parametersHolder = dentist.utils.CentroidsNumSpotsParametersHolder();
x = dentist.utils.CentroidsNumSpotsTextDisplayer(ax6, mockSource, channelHolder, ...
    parametersHolder, viewportHolder);
viewport.drawBoundaryRectangle('EdgeColor', 'g');

channelHolder.setChannelName('tmr')
x.draw()
title(sprintf('Another channel.'))

