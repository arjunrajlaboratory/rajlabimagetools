function [centroids, spots, assignedCentroids] = setupSpotsAndCentroids()
    
    [xs, ys] = dentist.tests.setupPoints();
    
    centroids = dentist.utils.Centroids(xs, ys);
    
    spotsCy = dentist.utils.Spots();
    spotsTmr = dentist.utils.Spots();
    assignedCentroidCy = [];
    assignedCentroidTmr = [];
    
   
    
    for i = 1:length(centroids)
        X = centroids.xPositions(i);
        Y = centroids.yPositions(i);
        numSpotsCy = 2 + round(5*rand(1));
        numSpotsTmr = 1 + round(3*rand(1));
        xCy = X + 1*(rand(numSpotsCy, 1) - 0.5);
        xTmr = X + 1*(rand(numSpotsTmr, 1) - 0.5);
        yCy = Y + 1*(rand(numSpotsCy, 1) - 0.5);
        yTmr = Y + 1*(rand(numSpotsTmr, 1) - 0.5);
        newSpotsCy = dentist.utils.Spots(xCy, yCy, zeros(size(xCy)));
        newSpotsTmr = dentist.utils.Spots(xTmr, yTmr, zeros(size(xTmr)));
        spotsCy = concatenate(spotsCy, newSpotsCy);
        spotsTmr = concatenate(spotsTmr, newSpotsTmr);
        assignedCentroidCy = [assignedCentroidCy; repmat(i, numSpotsCy, 1)];
        assignedCentroidTmr = [assignedCentroidTmr; repmat(i, numSpotsTmr, 1)];
    end
    
    assignedCentroids = dentist.utils.ChannelArray({'cy','tmr'});
    assignedCentroids = assignedCentroids.setByChannelName(assignedCentroidCy, 'cy');
    assignedCentroids = assignedCentroids.setByChannelName(assignedCentroidTmr, 'tmr');
    
    spots = dentist.utils.ChannelArray({'cy', 'tmr'});
    spots = spots.setByChannelName(spotsCy, 'cy');
    spots = spots.setByChannelName(spotsTmr, 'tmr');
end