function [ viewport, mockSource ] = setupForSpotsDisplayer()
    viewport = dentist.tests.setupImageViewport();
    
    [centroids, spots, assignedCentroids] = ...
        dentist.tests.setupSpotsAndCentroids();
    
    mockSource = dentist.tests.MockSpotsAndCentroidsSource(centroids, ...
        spots, assignedCentroids);
end

