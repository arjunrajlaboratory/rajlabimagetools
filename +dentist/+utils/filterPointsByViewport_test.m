dentist.tests.cleanupForTests;

[viewport, xs, ys] = dentist.tests.setupImageViewportAndPoints();

points = dentist.utils.Centroids(xs, ys);
    
img = rand(viewport.imageWidth, viewport.imageHeight);
figure(1); imshow(img, 'InitialMagnification', 'fit');
viewport.drawBoundaryRectangle('EdgeColor', 'g');

[keptPoints, keptIndices] = dentist.utils.filterPointsByViewport(points, viewport);

hold on
plot(points.xPositions, points.yPositions, '.r')
plot(keptPoints.xPositions, keptPoints.yPositions, 'or', 'MarkerSize', 10)
plot(points.xPositions(keptIndices), points.yPositions(keptIndices), 'or', 'MarkerSize', 20)

assert(all(sort(keptIndices)' == [2 4 11 12 15 16 17]))

title('points in ROI should have double circles. Outside no.')
