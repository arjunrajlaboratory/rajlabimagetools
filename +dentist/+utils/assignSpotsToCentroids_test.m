dentist.tests.cleanupForTests;

centroids = dentist.utils.Centroids([500,1000], [500,1000]);

sXY = [510, 510;    520, 520;   1500, 1500;     950, 950;   0, 500];
spots = dentist.utils.Spots(sXY(:,1), sXY(:,2), zeros(size(sXY,1)));

maxDistance = Inf;
[map, assignedSpots] = dentist.utils.assignSpotsToCentroids(spots, centroids, maxDistance);

assert(all(map == [1;1;2;2;1]));
assert(all(assignedSpots.xPositions == sXY(:,1)))

maxDistance = 100;
[map, assignedSpots] = dentist.utils.assignSpotsToCentroids(spots, centroids, maxDistance);

assert(all(map == [1;1;2]))
assert(all(assignedSpots.xPositions == sXY([1,2,4],1)))
