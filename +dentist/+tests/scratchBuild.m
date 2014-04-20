dentist.tests.cleanupForTests;

testDataDir = dentist.tests.data.locator();
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(testDataDir);
imageDirectoryReader.implementGridLayout(2,2,'down','right','nosnake');
numPixelOverlap = 103;
imageProvider = dentist.utils.ImageProvider(imageDirectoryReader, numPixelOverlap);

verboseFlag = false;
[spots, centroids, frequencyTables, thresholdsArray] = ...
    dentist.findSpotsAndCentroidsAllTiles(imageProvider, verboseFlag);

%%
maxDistance = 200;
[spotToCentroidMappings, assignedSpots] = spots.applyForEachChannel(...
    @dentist.utils.assignSpotsToCentroids, centroids, maxDistance);

%%

thresholdsInAllTiles = thresholdsArray.aggregateAllPositions(@(x,y) [x, y]);
thresholds = thresholdsInAllTiles.applyForEachChannel(@median);

%%

save('~/code/dentist_test/temp.mat', 'assignedSpots','centroids',...
    'spotToCentroidMappings','thresholds','frequencyTables')
