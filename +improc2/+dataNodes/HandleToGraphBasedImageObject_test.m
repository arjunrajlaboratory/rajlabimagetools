improc2.tests.cleanupForTests;

mask = [0 1 1 1 1; 0 1 1 1 0; 0 0 0 0 0];
dirPath = '~/tests/';
channelInfo.channelNames = {'cy', 'tmr', 'dapi'};
channelInfo.fileNames = {'cy002.tiff', 'tmr002.tiff', 'dapi002.tiff'};

graph = improc2.dataNodes.buildMinimalImageObjectGraph(mask, dirPath, channelInfo);

baseObj = improc2.dataNodes.GraphBasedImageObject();
baseObj.graph = graph;

objHolder = improc2.utils.ObjectHolder();
objHolder.obj = baseObj;

registrar = improc2.dataNodes.ProcessorRegistrarForGraphBasedImageObject(objHolder);
cyNumSpots = 5;
cySpotsData = improc2.tests.MockSpotsData(cyNumSpots);
tmrNumSpots = 7;
tmrSpotsData = improc2.tests.MockSpotsData(tmrNumSpots);
registrar.registerNewProcessor(cySpotsData, 'cy', 'cy:Spots')
registrar.registerNewProcessor(tmrSpotsData, 'tmr', 'tmr:Spots')

objWithSpotsData = objHolder.obj;

unprocessedFittedData = improc2.tests.MockFittedData();
registrar.registerNewProcessor(unprocessedFittedData, 'cy', 'cy:Fitted')
registrar.registerNewProcessor(unprocessedFittedData, 'tmr', 'tmr:Fitted')

objWithFittedData = objHolder.obj;


graphTester = improc2.tests.DataNodeGraphTester(objHolder);

x = improc2.dataNodes.HandleToGraphBasedImageObject(objHolder);

%% channelNames
channelNames = x.channelNames;
assert(isequal(channelNames, {'cy','tmr','dapi'}))

%% metaData

metaData = x.getMetaData();
expectedMetaData = baseObj.graph.nodes{1}.data.metadata;
assert(isequal( metaData, expectedMetaData))

%% Mask
imFileMask = x.getMask();
expectedImFileMask = mask;
assert(isequal(imFileMask, expectedImFileMask))

boundBox = x.getBoundingBox();
assert(isequal(boundBox, [2 1 3 1]))

croppedMask = x.getCroppedMask();
expectedCroppedMask = [1 1 1 1; 1 1 1 0];
assert(isequal(croppedMask, expectedCroppedMask))

%% Filenames

assert(isequal(x.getImageFileName('tmr'), 'tmr002.tiff'));
assert(isequal(x.getImageDirPath(), '~/tests/'))

%% Getting processors

objHolder.obj = objWithSpotsData;

assert(getNumSpots(x.getProcessorData('cy')) == cyNumSpots)
assert(getNumSpots(x.getProcessorData('tmr')) == tmrNumSpots)

assert(getNumSpots(x.getProcessorData('cy:Spots')) == cyNumSpots)
assert(getNumSpots(x.getProcessorData('cy', 'improc2.tests.MockSpotsData')) == cyNumSpots)
assert(getNumSpots(x.getProcessorData('cy', 'improc2.interfaces.SpotsProvider')) == cyNumSpots)

%% Getting: Ambiguous requests fail.

objHolder.obj = baseObj;

registrar.registerNewProcessor(improc2.tests.MockSpotsData(12), 'cy', 'cy:Spots1')
registrar.registerNewProcessor(improc2.tests.MockSpotsData(17), 'cy', 'cy:Spots2')

graphTester.assertIsImmediateChild('cy', 'cy:Spots1')
graphTester.assertIsImmediateChild('cy', 'cy:Spots2')

improc2.tests.shouldThrowError(@() x.getProcessorData('cy'), ...
    'improc2:AmbiguousDataSpecification')

assert(getNumSpots(x.getProcessorData('cy:Spots1')) == 12)
assert(getNumSpots(x.getProcessorData('cy:Spots2')) == 17)

%% Getting by data type

objHolder.obj = baseObj;

manualSpotsData = improc2.tests.MockManualSpotsData();
manualSpotsData.numSpots = 3;
registrar.registerNewProcessor(cySpotsData, 'cy', 'cy:Spots')
registrar.registerNewProcessor(manualSpotsData, 'cy', 'cy:Manual')

graphTester.assertIsImmediateChild('cy', 'cy:Spots')
graphTester.assertIsImmediateChild('cy', 'cy:Manual')

improc2.tests.shouldThrowError(@() x.getProcessorData('cy'), ...
    'improc2:AmbiguousDataSpecification')

assert(getNumSpots(x.getProcessorData('cy:Spots')) == cyNumSpots)
assert(getNumSpots(x.getProcessorData('cy:Manual')) == manualSpotsData.numSpots)

assert(getNumSpots(x.getProcessorData('cy', 'improc2.interfaces.ProcessedData')) == cyNumSpots)
assert(getNumSpots(x.getProcessorData('cy', 'improc2.tests.MockManualSpotsData')) == manualSpotsData.numSpots)