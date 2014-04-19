dentist.tests.cleanupForTests;

[viewport, mockSource] = dentist.tests.setupForCentroidsAndNumSpots();

img = zeros(viewport.imageWidth, viewport.imageHeight);
centroids = mockSource.getCentroids();
figure(1); 
subplotrows = 1;
subplotcols = 2;
ax1 = subplot(subplotrows,subplotcols,1); 
imshow(img, 'InitialMagnification', 'fit');
viewport.drawBoundaryRectangle('EdgeColor', 'g');

viewportHolder = dentist.utils.ViewportHolder(viewport);
parametersHolder = dentist.utils.CentroidsDisplayerParametersHolder();
channelHolder = dentist.utils.ChannelHolder('cy');

valToColorCy = dentist.utils.ValueToColorTranslator(...
    @(numSpots) numSpots/max(numSpots(:)), jet());
valToColorTmr = dentist.utils.ValueToColorTranslator(...
    @(numSpots) ones(size(numSpots)), [0 0 1]);
valToColorTranslators = dentist.utils.ChannelArray(mockSource.channelNames);
valToColorTranslators = valToColorTranslators.setByChannelName(valToColorCy, 'cy');
valToColorTranslators = valToColorTranslators.setByChannelName(valToColorTmr, 'tmr');

resources = struct();
resources.centroidsAndNumSpotsSource = mockSource;
resources.parametersHolder = parametersHolder;
resources.viewportHolder = viewportHolder;
resources.channelHolder = channelHolder;
resources.numSpotsToColorTranslators = valToColorTranslators;

x = dentist.utils.CentroidsDisplayer(ax1, resources);
x.draw();
title('draw')

ax2 = subplot(subplotrows,subplotcols,2); 
imshow(img, 'InitialMagnification', 'fit');
viewport.drawBoundaryRectangle('EdgeColor', 'g');

x = dentist.utils.CentroidsDisplayer(ax2, resources);
x.draw();
parametersHolder.set('spotsOrCircles', 'circles', 'circleRadius', 1)
x.draw();


