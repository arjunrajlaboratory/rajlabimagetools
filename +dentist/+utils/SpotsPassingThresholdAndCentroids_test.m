dentist.tests.cleanupForTests;

spotsCy = dentist.utils.Spots([0, 0], [0, 0], [5 10]);
spots = dentist.utils.ChannelArray({'cy'});
spots = spots.setByChannelName(spotsCy, 'cy');
centroids = dentist.utils.Centroids([0, 2], [0, 1]);
assignments = dentist.utils.ChannelArray({'cy'});
assignments = assignments.setByChannelName( [1;1], 'cy');

candidateSpotsAndCentroids = dentist.utils.SpotsAndCentroids(...
    spots, centroids, assignments);

thresholds = dentist.utils.ChannelArray({'cy'});
thresholds = thresholds.setByChannelName(0, 'cy');

thresholdsHolder = dentist.utils.ThresholdsHolder(thresholds);

x = dentist.utils.SpotsPassingThresholdAndCentroids(...
    candidateSpotsAndCentroids, thresholdsHolder);

c = x.getCentroids();
assert(all(c.xPositions == [0; 2]) && all(c.yPositions == [0; 1]))
s = x.getSpots('cy');
assert(length(s) == 2)
assert(all(s.intensities == [5;10]));
scmap = x.getSpotToCentroidMapping('cy');
assert(all(scmap == [1;1]));
nspots = x.getNumSpotsForCentroids('cy');
assert(all(nspots == [2; 0])) 

thresholdsHolder.setThreshold(6, 'cy');
s = x.getSpots('cy');
assert(length(s) == 1)
assert(all(s.intensities == [10]));
scmap = x.getSpotToCentroidMapping('cy');
assert(scmap == 1);
nspots = x.getNumSpotsForCentroids('cy');
assert(all(nspots == [1; 0]))

thresholdsHolder.setThreshold(10, 'cy');
s = x.getSpots('cy');
assert(length(s) == 0)
assert(isempty(s.intensities));
scmap = x.getSpotToCentroidMapping('cy');
assert(isempty(scmap));
nspots = x.getNumSpotsForCentroids('cy');
assert(all(nspots == [0; 0]))
