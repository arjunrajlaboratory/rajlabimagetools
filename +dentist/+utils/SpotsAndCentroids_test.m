dentist.tests.cleanupForTests;

spotsCy = dentist.utils.Spots([0, 0], [0, 0], [5 10]);
spots = dentist.utils.ChannelArray({'cy'});
spots = spots.setByChannelName(spotsCy, 'cy');
centroids = dentist.utils.Centroids([0, 2], [0, 1]);
assignments = dentist.utils.ChannelArray({'cy'});
assignments = assignments.setByChannelName( [1;1], 'cy');

x = dentist.utils.SpotsAndCentroids(spots, centroids, assignments);

c = x.getCentroids();
assert(all(c.xPositions == [0; 2]) && all(c.yPositions == [0; 1]))
s = x.getSpots('cy');
assert(length(s) == 2)
assert(all(s.intensities == [5;10]));
scmap = x.getSpotToCentroidMapping('cy');
assert(all(scmap == [1;1]));
[nspots, scmapagain] = x.getNumSpotsForCentroids('cy');
assert(all(nspots == [2; 0])) 
assert(all(scmapagain == [1;1]));
