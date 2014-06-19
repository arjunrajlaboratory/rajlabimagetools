function dentistData = processImages(dentistConfig)
    
    workingDirectory = pwd;
    if nargin < 1
        dentistConfig = dentist.utils.loadConfig(workingDirectory);
    end
    
    imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(...
        dentistConfig.dirPath);
    imageDirectoryReader.implementGridLayout(...
        dentistConfig.rows,...
        dentistConfig.cols,...
        dentistConfig.layout.nextFileDirection,...
        dentistConfig.layout.secondaryDirection,...
        dentistConfig.layout.snakeOrNoSnake);
    
    numPixelOverlap = dentistConfig.numPixelOverlap;
    
    imageProvider = dentist.utils.ImageProvider(imageDirectoryReader, numPixelOverlap);
    
    fprintf('Finding spots and centroids...\n')
    
    verboseFlag = false;
    [spots, centroids, frequencyTables, thresholdsArray] = ...
        dentist.findSpotsAndCentroidsAllTiles(imageProvider, verboseFlag);
    
    %%
    
    fprintf('Assigning spots to centroids...\n')
    
    maxDistance = dentistConfig.maxDistance;
    
    [spotToCentroidMappings, assignedSpots] = spots.applyForEachChannel(...
        @dentist.utils.assignSpotsToCentroids, centroids, maxDistance);
    
    %%
    thresholdsInAllTiles = thresholdsArray.aggregateAllPositions(@(x,y) [x, y]);
    thresholds = thresholdsInAllTiles.applyForEachChannel(@median);
    
    %%
    deletionPolygons = {};
    
    % DataSubsystem
    
    dentistData = struct();
    dentistData.centroids = centroids;
    dentistData.assignedSpots = assignedSpots;
    dentistData.spotToCentroidMappings = spotToCentroidMappings;
    dentistData.thresholds = thresholds;
    dentistData.frequencyTables = frequencyTables;
    dentistData.deletionPolygons = deletionPolygons;
    
    fprintf('Saving data...\n')
    dentist.utils.saveData(dentistData, workingDirectory);
    fprintf('DONE\n')
    