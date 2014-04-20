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
deletionPolygons = {};

% DataSubsystem

resources = struct();
resources.centroids = centroids;
resources.assignedSpots = assignedSpots;
resources.spotToCentroidMappings = spotToCentroidMappings;
resources.thresholds = thresholds;
resources.frequencyTables = frequencyTables;
resources.deletionPolygons = deletionPolygons;

data = dentist.buildDataSubystem(resources);
thumbnails = assignedSpots.applyForEachChannel(@(x) rand(1000,1000));

% MakeGUI 

gui = dentist.createAndLayOutMainGUI();

% Channel Setting

channelSynchronizer = dentist.utils.ChannelSwitchCoordinator(...
    data.spotsAndCentroids.channelNames);
channelSynchronizer.attachUIControl(gui.chanPop);

% Hot to translate Numspots into colors

makeDefaultColorer = @() dentist.utils.ValueToColorTranslator(...
    @(numSpots) numSpots/max(numSpots(:)), jet(64));
numSpotsToColorTranslators = dentist.utils.makeFilledChannelArray(...
    channelSynchronizer.channelNames, @(channelName) makeDefaultColorer());

% Thumbnails
resources = struct();
resources.centroidsAndNumSpotsSource = data.spotsAndCentroids;
resources.numSpotsToColorTranslators = numSpotsToColorTranslators;
resources.imageWidthAndHeight = dentist.utils.computeTiledImageWidthAndHeight(...
    imageProvider);

thumbnailMakers = dentist.buildThumbnailMakers(resources);
thumbnailFactory = dentist.utils.ThumbnailMakingFactory(thumbnailMakers);
thumbnailFactory.setThumbnailWidthAndHeight(1000, 1000)
thumbnailFactory.setPixelExpansionSize(201)
thumbnailFactory.makeAllThumbnails()
thumbnailsProvider = dentist.utils.ThumbnailsProvider(thumbnailMakers);
coloringAndThumbnailSettings = dentist.utils.ColoringAndThumbnailSettings(...
    numSpotsToColorTranslators, thumbnailMakers, channelSynchronizer);

set(gui.makeThumbnailsButton, 'CallBack', ...
    @(varargin) thumbnailFactory.makeAllThumbnails())

% Image subsystem

resources = struct(); 
resources.gui =  gui;
resources.imageProvider = imageProvider;
resources.spotsAndCentroids = data.spotsAndCentroids;
resources.thumbnails = thumbnailsProvider;
resources.channelHolder = channelSynchronizer;
resources.numSpotsToColorTranslators = numSpotsToColorTranslators;

resources.centroidRadiusPixels = 60;
resources.zoomTransitionFineToMedium = 800;
resources.zoomTransitionMediumToWide = 1600;

displaySubsystem = dentist.buildImageSubsystem(resources);

data.thresholdsHolder.addActionOnUpdate(displaySubsystem, @draw);
data.deletionsSubsystem.addActionAfterDeletion(displaySubsystem, @draw);
channelSynchronizer.addActionAfterChannelSwitch(displaySubsystem, @draw);
coloringAndThumbnailSettings.addActionOnSettingsChange(displaySubsystem, @draw);
thumbnailFactory.addActionAfterMakingThumbnails(displaySubsystem, @draw);

% centroids list box subsystem

resources = struct();
resources.gui =  gui;
resources.spotsAndCentroids = data.spotsAndCentroids;
resources.viewportHolder = displaySubsystem;
resources.channelHolder = channelSynchronizer;

configurations = struct();
configurations.sizeOfViewportWhenFocusedOnCentroid = 800;

listBoxSubsystem = dentist.buildCentroidsListBoxSubsystem(resources, configurations);

data.thresholdsHolder.addActionOnUpdate(listBoxSubsystem, @draw);
data.deletionsSubsystem.addActionAfterDeletion(listBoxSubsystem, @draw);
channelSynchronizer.addActionAfterChannelSwitch(listBoxSubsystem, @draw);

% threshold Plot subsystem

resources = struct();
resources.gui = gui;
resources.frequencyTableSource = data.frequencyTableSource;
resources.thresholdsHolder = data.thresholdsHolder;
resources.channelHolder = channelSynchronizer;

thresholdPlotSubsystem = dentist.buildThresholdPlotSubsystem(resources);

data.thresholdsHolder.addActionOnUpdate(thresholdPlotSubsystem, @draw);
data.deletionsSubsystem.addActionAfterDeletion(thresholdPlotSubsystem, @draw);
channelSynchronizer.addActionAfterChannelSwitch(thresholdPlotSubsystem, @draw);

% DeletionsUISubsystem

resources = struct();
resources.gui = gui;
resources.deletionsSubsystem = data.deletionsSubsystem;

deletionsUISubsystem = dentist.buildDeletionsUISubsystem(resources);

displaySubsystem.addActionAfterViewportUpdate(deletionsUISubsystem, @draw);
data.thresholdsHolder.addActionOnUpdate(deletionsUISubsystem, @draw);
data.deletionsSubsystem.addActionAfterDeletion(deletionsUISubsystem, @draw);
channelSynchronizer.addActionAfterChannelSwitch(deletionsUISubsystem, @draw);

% Add interactions

resources = struct();
resources.gui = gui;
resources.displaySubsystem = displaySubsystem;
resources.deletionsUISubsystem = deletionsUISubsystem;

dentist.addImageAndThumbnailInteractions(resources);
