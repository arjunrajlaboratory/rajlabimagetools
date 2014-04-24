dentist.tests.cleanupForTests;

spotsCy = dentist.utils.Spots([0.5, 2], [0.75, 1.5], [5 10]);
spots = dentist.utils.ChannelArray({'cy'});
spots = spots.setByChannelName(spotsCy, 'cy');
centroids = dentist.utils.Centroids([0, 2], [0, 1]);
assignments = dentist.utils.ChannelArray({'cy'});
assignments = assignments.setByChannelName( [1;2], 'cy');

originalSpotsAndCentroids = ...
    dentist.utils.SpotsAndCentroids(spots, centroids, assignments);

x = dentist.utils.DeleteableSpotsAndCentroids(originalSpotsAndCentroids);

c = x.getCentroids();
assert(all(c.xPositions == [0; 2]) && all(c.yPositions == [0; 1]))
s = x.getSpots('cy');
assert(length(s) == 2)
assert(all(s.intensities == [5;10]));
scmap = x.getSpotToCentroidMapping('cy');
assert(all(scmap == [1;2]));
[nspots, scmapagain] = x.getNumSpotsForCentroids('cy');
assert(all(nspots == [1; 1])) 
assert(all(scmapagain == [1;2]));

%% deletion of all

x.deleteByXYFilter(@(x,y) true([1 length(x)]))
c = x.getCentroids();
assert(length(c) == 0)
s = x.getSpots('cy');
assert(length(s) == 0)
scmap = x.getSpotToCentroidMapping('cy');
assert(isempty(scmap));
[nspots, scmapagain] = x.getNumSpotsForCentroids('cy');
assert(isempty(nspots))
assert(isempty(scmapagain))




%% undelete

x.unDeleteAll()

c = x.getCentroids();
assert(all(c.xPositions == [0; 2]) && all(c.yPositions == [0; 1]))
s = x.getSpots('cy');
assert(length(s) == 2)
assert(all(s.intensities == [5;10]));
scmap = x.getSpotToCentroidMapping('cy');
assert(all(scmap == [1;2]));
[nspots, scmapagain] = x.getNumSpotsForCentroids('cy');
assert(all(nspots == [1; 1])) 
assert(all(scmapagain == [1;2]));

%% deletion of centroids deletes associated spots.

x.deleteByXYFilter(@(x,y) x == 2 & y == 1)

c = x.getCentroids();
assert(all(c.xPositions == [0]) && all(c.yPositions == [0]))
s = x.getSpots('cy');
assert(all(s.intensities == [5]));
scmap = x.getSpotToCentroidMapping('cy');
assert(all(scmap == [1]));
[nspots, scmapagain] = x.getNumSpotsForCentroids('cy');
assert(all(nspots == [1])) 
assert(all(scmapagain == [1]));

% deletions are cumulative

x.deleteByXYFilter(@(x,y) x == 0 & y == 0)
c = x.getCentroids();
assert(length(c) == 0)
s = x.getSpots('cy');
assert(length(s) == 0)
scmap = x.getSpotToCentroidMapping('cy');
assert(isempty(scmap));
[nspots, scmapagain] = x.getNumSpotsForCentroids('cy');
assert(isempty(nspots))
assert(isempty(scmapagain))

x.unDeleteAll()

%% spots matching criteria are deleted even if centroid is kept.

x.deleteByXYFilter(@(x,y) x == 0.5 & y == 0.75)
c = x.getCentroids();
assert(all(c.xPositions == [0; 2]) && all(c.yPositions == [0; 1]))
s = x.getSpots('cy');
assert(all(s.intensities == [10]));
scmap = x.getSpotToCentroidMapping('cy');
assert(all(scmap == [2]));
[nspots, scmapagain] = x.getNumSpotsForCentroids('cy');
assert(all(nspots == [0; 1])) 
assert(all(scmapagain == [2]));

%% setting deletions rather than deleting will first reset and then delete.

x.setDeletionsToMatchXYFilter(@(x,y) x == 2 & y == 1)

c = x.getCentroids();
assert(all(c.xPositions == [0]) && all(c.yPositions == [0]))
s = x.getSpots('cy');
assert(all(s.intensities == [5]));
scmap = x.getSpotToCentroidMapping('cy');
assert(all(scmap == [1]));
[nspots, scmapagain] = x.getNumSpotsForCentroids('cy');
assert(all(nspots == [1])) 
assert(all(scmapagain == [1]));
