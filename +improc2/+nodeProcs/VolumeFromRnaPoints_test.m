%% Run this to calculate volume for a single image object

improc2.tests.cleanupForTests;

dataFiles = improc2.utils.ImageObjectDataFiles();
onDisk = improc2.utils.FileBasedImageObjectArrayCollection(dataFiles);
collection = improc2.utils.loadCollectionIntoMemory(onDisk);

tools = improc2.launchImageObjectBrowsingTools(collection);

mockMaskContainer = struct();
mockMaskContainer.mask = tools.objectHandle.getCroppedMask();

dapiProcData = tools.objectHandle.getData('dapi');

nirSpotsData = tools.objectHandle.getData('nir');

%Spacing between planes in z-stack, in microns
planeSpacing = 0.25;
%Width of one pixel, in microns
xyPixelWidth = 0.125;

x = improc2.nodeProcs.VolumeFromRnaPoints(planeSpacing,xyPixelWidth);

xProcessed = run(x, mockMaskContainer, dapiProcData, nirSpotsData);


%% Run this to calculate volume for a collection of image objects

improc2.tests.cleanupForTests;

dataFiles = improc2.utils.ImageObjectDataFiles();
onDisk = improc2.utils.FileBasedImageObjectArrayCollection(dataFiles);
dataAdder = improc2.processing.DataAdder(onDisk);

zPlaneSpacing = 0.25;
xyPixelWidth = 0.125;

highDensitySpotsChannel = 'nir';

dataAdder.addDataToObject(improc2.nodeProcs.VolumeFromRnaPoints(zPlaneSpacing,xyPixelWidth),...
    {'imageObject','dapi',highDensitySpotsChannel},'volume');
dataAdder.repeatForAllObjectsAndQuit();

improc2.processing.updateAll(onDisk);

%% This examines volume from individual data files

dataFiles = improc2.utils.ImageObjectDataFiles();
onDisk = improc2.utils.FileBasedImageObjectArrayCollection(dataFiles);
collection = improc2.utils.loadCollectionIntoMemory(onDisk);
tools = improc2.launchImageObjectTools(collection);
tools.iterator.goToFirstObject
volumeData = tools.objectHandle.getData('volume');
volumeData.volumeRealUnits

%% This extracts volume data and spot counts from two channels

extractor = improc2.launchDataExtractor();
extractor.extractFromProcessorData('low-concentration RNA count',@getNumSpots,'alexa:Spots');
extractor.extractFromProcessorData('high-concentration RNA count',@getNumSpots,'nir:Spots');
extractor.extractFromProcessorData('cell volume','volumeRealUnits','volume');
extractor.extractAllToCSVFile('~/Desktop/CountsAndVolume.csv')