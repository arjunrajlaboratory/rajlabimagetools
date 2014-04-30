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

assert(isequal(sort(x.channelNames), sort({'cy','tmr','dapi'})))

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

%% Setting data:

modifiedCyNumSpots = 2*cyNumSpots + 1;
modifiedCySpotsData = improc2.tests.MockSpotsData(modifiedCyNumSpots);


objHolder.obj = objWithSpotsData;
assert(getNumSpots(x.getProcessorData('cy')) == cyNumSpots)
x.setProcessorData(modifiedCySpotsData, 'cy')
assert(getNumSpots(x.getProcessorData('cy')) == modifiedCyNumSpots)

objHolder.obj = objWithSpotsData;
assert(getNumSpots(x.getProcessorData('cy')) == cyNumSpots)
x.setProcessorData(modifiedCySpotsData, 'cy:Spots')
assert(getNumSpots(x.getProcessorData('cy')) == modifiedCyNumSpots)

objHolder.obj = objWithSpotsData;
assert(getNumSpots(x.getProcessorData('cy')) == cyNumSpots)
x.setProcessorData(modifiedCySpotsData, 'cy', 'improc2.tests.MockSpotsData')
assert(getNumSpots(x.getProcessorData('cy')) == modifiedCyNumSpots)

objHolder.obj = objWithSpotsData;
assert(getNumSpots(x.getProcessorData('cy')) == cyNumSpots)
x.setProcessorData(modifiedCySpotsData, 'cy', 'improc2.interfaces.SpotsProvider')
assert(getNumSpots(x.getProcessorData('cy')) == modifiedCyNumSpots)

%% Setting data: Replacement must be of the same class

objHolder.obj = objWithSpotsData;

improc2.tests.shouldThrowError(...
    @() x.setProcessorData(manualSpotsData, 'cy'), 'improc2:BadArguments')

%% Setting data: error if ambiguous

objHolder.obj = baseObj;

registrar.registerNewProcessor(cySpotsData, 'cy', 'cy:Spots')
registrar.registerNewProcessor(manualSpotsData, 'cy', 'cy:Manual')

objWithCySpotsAndManual = objHolder.obj;

graphTester.assertIsImmediateChild('cy', 'cy:Spots')
graphTester.assertIsImmediateChild('cy', 'cy:Manual')

improc2.tests.shouldThrowError(@() x.setProcessorData(modifiedCySpotsData, 'cy'), ...
    'improc2:AmbiguousDataSpecification')
assert(getNumSpots(x.getProcessorData('cy:Spots')) == cyNumSpots)

%% Setting data: specifying by node label and data type

objHolder.obj = objWithCySpotsAndManual;
assert(getNumSpots(x.getProcessorData('cy:Spots')) == cyNumSpots)
x.setProcessorData(modifiedCySpotsData, 'cy:Spots')
assert(getNumSpots(x.getProcessorData('cy:Spots')) == modifiedCyNumSpots)

objHolder.obj = objWithCySpotsAndManual;
assert(getNumSpots(x.getProcessorData('cy:Spots')) == cyNumSpots)
x.setProcessorData(modifiedCySpotsData, 'cy', 'improc2.tests.MockSpotsData')
assert(getNumSpots(x.getProcessorData('cy:Spots')) == modifiedCyNumSpots)

%% Setting data: needsUpdate propagation

objHolder.obj = baseObj;

% artificially set all needsUpdate to false first:
cyProcessedSpotsData = cySpotsData;
tmrProcessedSpotsData = tmrSpotsData;
cyProcessedSpotsData.needsUpdate = false;
tmrProcessedSpotsData.needsUpdate = false;

cyProcessedFitted = improc2.tests.MockFittedData();
cyProcessedFitted.needsUpdate = false;
tmrProcessedFitted = improc2.tests.MockFittedData();
tmrProcessedFitted.needsUpdate = false;

processedColocolizer = improc2.tests.MockColocolizerData();
processedColocolizer.needsUpdate = false;

registrar.registerNewProcessor(cyProcessedSpotsData, 'cy', 'cy:Spots')
registrar.registerNewProcessor(tmrProcessedSpotsData, 'tmr', 'tmr:Spots')
registrar.registerNewProcessor(cyProcessedFitted, 'cy', 'cy:Fitted')
registrar.registerNewProcessor(tmrProcessedFitted, 'tmr', 'tmr:Fitted')
registrar.registerNewProcessor(processedColocolizer, ...
    {'cy:Fitted', 'tmr:Fitted'}, 'coloc')

graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted', ...
    'tmr:Fitted', 'coloc')

% even setting data back to itself, triggers updates.
x.setProcessorData(cyProcessedSpotsData, 'cy:Spots')
graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots','tmr:Fitted')
graphTester.assertNeedUpdate('cy:Fitted', 'coloc')

x.setProcessorData(tmrProcessedSpotsData, 'tmr:Spots')
graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots')
graphTester.assertNeedUpdate('cy:Fitted', 'coloc', 'tmr:Fitted')

%% HasData:

objHolder.obj = baseObj;

objHolder.obj = objWithSpotsData;
assert(x.hasProcessorData('cy'))
assert(x.hasProcessorData('cy:Spots'))
assert(x.hasProcessorData('cy', 'improc2.tests.MockSpotsData'))
assert(x.hasProcessorData('cy', 'improc2.interfaces.SpotsProvider'))
assert(~ x.hasProcessorData('cy', 'improc2.tests.MockFittedData'))

registrar.registerNewProcessor(improc2.tests.MockFittedData(), 'cy', 'cy:Fitted')

assert(x.hasProcessorData('cy', 'improc2.tests.MockFittedData'))
assert(~ x.hasProcessorData('tmr', 'improc2.tests.MockFittedData'))

% getting would fail due to ambiguity, but 'has' query succeeds.
assert(x.hasProcessorData('cy'))

%% runProcessor: clears needsUpdate flag to false

objHolder.obj = objWithSpotsData;

imageProviders = dentist.utils.makeFilledChannelArray({'cy','tmr'}, ...
    @(channelName) improc2.tests.MockCroppedImageProvider());

graphTester.assertNeedUpdate('cy:Spots')
x.runProcessor(imageProviders, 'cy')
graphTester.assertDoNotNeedUpdate('cy:Spots')

%% runProcessor: automatically grabbing dependencies.

objHolder.obj = objWithFittedData;

graphTester.assertNeedUpdate('cy:Spots','cy:Fitted')
assert(getNumSpots(x.getProcessorData('cy:Spots')) == cyNumSpots)
assert(isempty(getNumSpots(x.getProcessorData('cy:Fitted'))))

x.runProcessor(imageProviders, 'cy:Spots')

graphTester.assertNeedUpdate('cy:Fitted')
graphTester.assertDoNotNeedUpdate('cy:Spots')
assert(isempty(getNumSpots(x.getProcessorData('cy:Fitted'))))

x.runProcessor(imageProviders, 'cy:Fitted')

graphTester.assertDoNotNeedUpdate('cy:Spots', 'cy:Fitted')
assert(getNumSpots(x.getProcessorData('cy:Spots')) == cyNumSpots)
assert(getNumSpots(x.getProcessorData('cy:Fitted')) == cyNumSpots)


x.runProcessor(imageProviders, 'tmr:Spots')
x.runProcessor(imageProviders, 'tmr:Fitted')

graphTester.assertDoNotNeedUpdate('cy:Spots', 'cy:Fitted', 'tmr:Spots', 'tmr:Fitted')

registrar.registerNewProcessor(improc2.tests.MockColocolizerData(), ...
    {'cy:Fitted', 'tmr:Fitted'}, 'coloc')

graphTester.assertNeedUpdate('coloc')
colocData = x.getProcessorData('coloc');
assert(isempty(colocData.numSpotsA))
assert(isempty(colocData.numSpotsB))

x.runProcessor(imageProviders, 'coloc')

graphTester.assertDoNotNeedUpdate('coloc')
colocData = x.getProcessorData('coloc');
assert(colocData.numSpotsA == cyNumSpots)
assert(colocData.numSpotsB == tmrNumSpots)

objProcessedUpToColoc = objHolder.obj;

%% Running: supplying image providers

objHolder.obj = objProcessedUpToColoc;

% the first argument is ignored if running the processor does not require
% raw images.
x.runProcessor({}, 'coloc') 
% but will treat the first input as a dentist.utils.ChannelArray if
% images are required for processing.
improc2.tests.shouldThrowError(@() x.runProcessor({}, 'cy:Spots'))

% need only supply a provider array for the channels used:

cyOnlyProvider = dentist.utils.makeFilledChannelArray({'cy'}, ...
    @(channelName) improc2.tests.MockCroppedImageProvider());

x.runProcessor(cyOnlyProvider, 'cy:Spots')
improc2.tests.shouldThrowError(@() x.runProcessor(cyOnlyProvider, 'tmr:Spots'), ...
    'dentist:NoSuchChannel')

%% Running: triggering needsUpdate in dependents

objHolder.obj = objProcessedUpToColoc;

graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted', ...
    'tmr:Fitted', 'coloc')

% rerunning triggers need for update:
x.runProcessor(imageProviders, 'cy:Fitted')
graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots','tmr:Fitted','cy:Fitted')
graphTester.assertNeedUpdate('coloc')

x.runProcessor(imageProviders, 'tmr:Spots')
graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted')
graphTester.assertNeedUpdate('coloc', 'tmr:Fitted')

%% Running: Fails if dependency needs update

objHolder.obj = objProcessedUpToColoc;

graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted', ...
    'tmr:Fitted', 'coloc')

x.runProcessor(imageProviders, 'tmr:Spots')
graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted')
graphTester.assertNeedUpdate('coloc', 'tmr:Fitted')

improc2.tests.shouldThrowError( @() x.runProcessor({}, 'coloc'), ...
    'improc2:DependencyNeedsUpdate')

%% Updating: will run everything runnable in the tree.

objHolder.obj = objWithFittedData;
registrar.registerNewProcessor(improc2.tests.MockColocolizerData(), ...
    {'cy:Fitted', 'tmr:Fitted'}, 'coloc')


graphTester.assertNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted', ...
    'tmr:Fitted', 'coloc')
assert(isempty(getNumSpots(x.getProcessorData('tmr:Fitted'))))
assert(isempty(getNumSpots(x.getProcessorData('cy:Fitted'))))
colocData = x.getProcessorData('coloc');
assert(isempty(colocData.numSpotsA))
assert(isempty(colocData.numSpotsB))

x.updateAllProcessedData(imageProviders)

graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted', ...
    'tmr:Fitted', 'coloc')

assert(getNumSpots(x.getProcessorData('tmr:Fitted')) == tmrNumSpots)
assert(getNumSpots(x.getProcessorData('cy:Fitted')) == cyNumSpots)
colocData = x.getProcessorData('coloc');
assert(colocData.numSpotsA == cyNumSpots)
assert(colocData.numSpotsB == tmrNumSpots)

%% Updating: will not update (but won't throw error) if there is a dependent

objHolder.obj = baseObj;

registrar.registerNewProcessor(improc2.tests.MockManualSpotsData(), 'cy', 'cy:Manual')
registrar.registerNewProcessor(tmrSpotsData, 'tmr', 'tmr:Spots')
registrar.registerNewProcessor(improc2.tests.MockFittedData(), {'cy:Manual', 'cy'}, 'cy:FittedToManual')
registrar.registerNewProcessor(improc2.tests.MockFittedData(), {'tmr:Spots', 'tmr'}, 'tmr:Fitted')
registrar.registerNewProcessor(improc2.tests.MockColocolizerData(), ...
    {'cy:FittedToManual', 'tmr:Fitted'}, 'coloc')

graphTester.assertNeedUpdate('cy:Manual', 'cy:FittedToManual', ...
    'tmr:Spots', 'tmr:Fitted', 'coloc')

assert(~isa(x.getProcessorData('cy:Manual'), 'improc2.interfaces.ProcessedData'))

x.updateAllProcessedData(imageProviders)

graphTester.assertDoNotNeedUpdate('tmr:Spots', 'tmr:Fitted')
graphTester.assertNeedUpdate('cy:Manual', 'cy:FittedToManual', 'coloc')

cyManual = x.getProcessorData('cy:Manual');
cyManual.numSpots = 35;
cyManual.needsUpdate = false;
x.setProcessorData(cyManual, 'cy:Manual')

x.updateAllProcessedData(imageProviders)

graphTester.assertDoNotNeedUpdate('cy:Manual', 'cy:FittedToManual', ...
    'tmr:Spots', 'tmr:Fitted', 'coloc')
