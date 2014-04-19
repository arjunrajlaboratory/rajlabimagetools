improc2.tests.cleanupForTests;

positions = [1,1;...
    2,2; ...
    2.3,1.8;...
    1.1, 0.9];

groupings = [1, 2, 3, 4];
    
centroids = dentist.utils.Centroids(positions(:,1), positions(:,2));
centroidsSource = dentist.tests.MockCentroidsAndNumSpotsSource(centroids, []);
centroidGroupings = improc2.tests.MockGroupableItems(groupings);

grouper = improc2.utils.Grouper(centroidGroupings);

polygonBasedGrouper = improc2.utils.PolygonBasedCentroidsGrouper(...
    grouper, centroidsSource);

getGroupings = @() arrayfun(...
    @(x) centroidGroupings.getGroupAssignedTo(x), ...
    1:length(centroidGroupings));

assert(isequal(getGroupings(), groupings))

polygonIncludingNothing = [3,3; 3, 5; 5, 5; 5, 3];
polygonBasedGrouper.groupAllInPolygon(polygonIncludingNothing);
assert(isequal(getGroupings(), groupings))

polygonIncludingTheOneOnes = [0,0; 0, 1.5; 1.5, 1.5; 1.5, 0];
polygonBasedGrouper.groupAllInPolygon(polygonIncludingTheOneOnes)
assert(isequal(getGroupings(), [1, 2, 3, 1]));

polygonIncludingTheTwoTwos = [3,3; 3, 1.5; 1.5, 1.5; 1.5, 3];
polygonBasedGrouper.groupAllInPolygon(polygonIncludingTheTwoTwos)
assert(isequal(getGroupings(), [1, 2, 2, 1]));

polygonIncludingAll = [3,3; 3, 0; 0, 0; 0, 3];
polygonBasedGrouper.groupAllInPolygon(polygonIncludingAll)
assert(isequal(getGroupings(), [1, 1, 1, 1]));




