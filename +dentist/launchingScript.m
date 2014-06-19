
workingDirectory = pwd;

if ~exist('dentistConfig', 'var')
    dentistConfig = dentist.utils.loadConfig(workingDirectory);
end

if ~exist('dentistData', 'var')
    dentistData = dentist.utils.loadData(workingDirectory);
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


% DataSubsystem

resources = dentistData;
dataSystem = dentist.buildDataSubystem(resources);

% Data saver:



% MakeGUI 

gui = dentist.createAndLayOutMainGUI();

% Channel Setting

channelSynchronizer = dentist.utils.ChannelSwitchCoordinator(...
    dataSystem.spotsAndCentroids.channelNames);
channelSynchronizer.attachUIControl(gui.chanPop);

% Hot to translate Numspots into colors

makeDefaultColorer = @() dentist.utils.ValueToColorTranslator(...
    @(numSpots) numSpots/max(numSpots(:)), jet(64));
numSpotsToColorTranslators = dentist.utils.makeFilledChannelArray(...
    channelSynchronizer.channelNames, @(channelName) makeDefaultColorer());

% Thumbnails
resources = struct();
resources.centroidsAndNumSpotsSource = dataSystem.spotsAndCentroids;
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
resources.spotsAndCentroids = dataSystem.spotsAndCentroids;
resources.thumbnails = thumbnailsProvider;
resources.channelHolder = channelSynchronizer;
resources.numSpotsToColorTranslators = numSpotsToColorTranslators;

resources.centroidRadiusPixels = 60;
resources.zoomTransitionFineToMedium = 800;
resources.zoomTransitionMediumToWide = 1600;

displaySubsystem = dentist.buildImageSubsystem(resources);

dataSystem.thresholdsHolder.addActionOnUpdate(displaySubsystem, @draw);
dataSystem.deletionsSubsystem.addActionAfterDeletion(displaySubsystem, @draw);
channelSynchronizer.addActionAfterChannelSwitch(displaySubsystem, @draw);
coloringAndThumbnailSettings.addActionOnSettingsChange(displaySubsystem, @draw);
thumbnailFactory.addActionAfterMakingThumbnails(displaySubsystem, @draw);

% centroids list box subsystem

resources = struct();
resources.gui =  gui;
resources.spotsAndCentroids = dataSystem.spotsAndCentroids;
resources.viewportHolder = displaySubsystem;
resources.channelHolder = channelSynchronizer;

configurations = struct();
configurations.sizeOfViewportWhenFocusedOnCentroid = 800;

listBoxSubsystem = dentist.buildCentroidsListBoxSubsystem(resources, configurations);

dataSystem.thresholdsHolder.addActionOnUpdate(listBoxSubsystem, @draw);
dataSystem.deletionsSubsystem.addActionAfterDeletion(listBoxSubsystem, @draw);
channelSynchronizer.addActionAfterChannelSwitch(listBoxSubsystem, @draw);

% threshold Plot subsystem

resources = struct();
resources.gui = gui;
resources.frequencyTableSource = dataSystem.frequencyTableSource;
resources.thresholdsHolder = dataSystem.thresholdsHolder;
resources.channelHolder = channelSynchronizer;

thresholdPlotSubsystem = dentist.buildThresholdPlotSubsystem(resources);

dataSystem.thresholdsHolder.addActionOnUpdate(thresholdPlotSubsystem, @draw);
dataSystem.deletionsSubsystem.addActionAfterDeletion(thresholdPlotSubsystem, @draw);
channelSynchronizer.addActionAfterChannelSwitch(thresholdPlotSubsystem, @draw);

% DeletionsUISubsystem

resources = struct();
resources.gui = gui;
resources.deletionsSubsystem = dataSystem.deletionsSubsystem;

deletionsUISubsystem = dentist.buildDeletionsUISubsystem(resources);

displaySubsystem.addActionAfterViewportUpdate(deletionsUISubsystem, @draw);
dataSystem.thresholdsHolder.addActionOnUpdate(deletionsUISubsystem, @draw);
dataSystem.deletionsSubsystem.addActionAfterDeletion(deletionsUISubsystem, @draw);
channelSynchronizer.addActionAfterChannelSwitch(deletionsUISubsystem, @draw);

% Add interactions

resources = struct();
resources.gui = gui;
resources.displaySubsystem = displaySubsystem;
resources.deletionsUISubsystem = deletionsUISubsystem;

dentist.addImageAndThumbnailInteractions(resources);
