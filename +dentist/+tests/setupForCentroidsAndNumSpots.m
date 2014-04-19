function [viewport, mockSource] = setupForCentroidsAndNumSpots()
    [viewport, xs, ys] = dentist.tests.setupImageViewportAndPoints();
    numspotsCy = [33    45    74    51    38    91    97    63 ...
        13    62 38    99    29    71    54    19    69];
    numspotsTmr = [5    18     5    89    84    12    41    12 ...
        57    95 26    99    35    21    67    97    62];
    numspots = dentist.utils.ChannelArray({'cy','tmr'});
    numspots = numspots.setByChannelName(numspotsCy, 'cy');
    numspots = numspots.setByChannelName(numspotsTmr, 'tmr');
    centroids = dentist.utils.Centroids(xs, ys);
    mockSource = dentist.tests.MockCentroidsAndNumSpotsSource(centroids, numspots);
end

