improc2.tests.cleanupForTests;

positions = [1,1;...
    2,2; ...
    2.3,1.8;...
    1.1, 0.9];

groupings = [3, 5, 5, 3];
    
centroids = dentist.utils.Centroids(positions(:,1), positions(:,2));
centroidsSource = dentist.tests.MockCentroidsAndNumSpotsSource(centroids, []);
centroidGroupings = improc2.tests.MockGroupableItems(groupings);


figure(1); axH = axes(); xlim([0 3]); ylim([0 3])

x = improc2.utils.GroupedCentroidsDisplayer(axH, ...
    centroidsSource, centroidGroupings);

x.draw();

title('Expect to see two 3s near 1,1 and two 5s near 2,2')