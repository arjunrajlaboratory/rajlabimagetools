improc2.tests.cleanupForTests;

mask = [0 1 1 1 1; 0 1 1 1 0; 0 0 0 0 0];
dirPath = '~/tests/';
channelInfo.channelNames = {'cy', 'tmr', 'dapi'};
channelInfo.fileNames = {'cy002.tiff', 'tmr002.tiff', 'dapi002.tiff'};

graph = improc2.dataNodes.buildMinimalImageObjectGraph(mask, dirPath, channelInfo);

baseObj = improc2.dataNodes.GraphBasedImageObject();
baseObj.graph = graph;
baseObj.metadata.testField = 'testValue';

objHolder = improc2.utils.ObjectHolder();
objHolder.obj = baseObj;

registrar = improc2.dataNodes.ProcessorRegistrarForGraphBasedImageObject(objHolder);
cyNumSpots = 5;
cySpotsData = improc2.tests.MockSpotsData(cyNumSpots);
tmrNumSpots = 7;
tmrSpotsData = improc2.tests.MockSpotsData(tmrNumSpots);
registrar.registerNewData(cySpotsData, 'cy', 'cy:Spots')
registrar.registerNewData(tmrSpotsData, 'tmr', 'tmr:Spots')

objWithSpotsData = objHolder.obj;

unprocessedFittedData = improc2.tests.MockFittedData();
registrar.registerNewData(unprocessedFittedData, 'cy', 'cy:Fitted')
registrar.registerNewData(unprocessedFittedData, 'tmr', 'tmr:Fitted')

objWithFittedData = objHolder.obj;


graphTester = improc2.tests.DataNodeGraphTester(objHolder);

x = improc2.dataNodes.HandleToGraphBasedImageObject(objHolder);

%% channelNames

assert(isequal(sort(x.channelNames), sort({'cy','tmr','dapi'})))

%% metaData

metaData = x.getMetaData();
assert(isequal( metaData.testField, baseObj.metadata.testField))

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

assert(getNumSpots(x.getData('cy')) == cyNumSpots)
assert(getNumSpots(x.getData('tmr')) == tmrNumSpots)

assert(getNumSpots(x.getData('cy:Spots')) == cyNumSpots)
assert(getNumSpots(x.getData('cy', 'improc2.tests.MockSpotsData')) == cyNumSpots)
assert(getNumSpots(x.getData('cy', 'improc2.interfaces.SpotsProvider')) == cyNumSpots)

%% Getting: Ambiguous requests fail.

objHolder.obj = baseObj;

registrar.registerNewData(improc2.tests.MockSpotsData(12), 'cy', 'cy:Spots1')
registrar.registerNewData(improc2.tests.MockSpotsData(17), 'cy', 'cy:Spots2')

graphTester.assertIsImmediateChild('cy', 'cy:Spots1')
graphTester.assertIsImmediateChild('cy', 'cy:Spots2')

improc2.tests.shouldThrowError(@() x.getData('cy'), ...
    'improc2:AmbiguousDataSpecification')

assert(getNumSpots(x.getData('cy:Spots1')) == 12)
assert(getNumSpots(x.getData('cy:Spots2')) == 17)

%% Getting by data type

objHolder.obj = baseObj;

manualSpotsData = improc2.tests.MockManualSpotsData();
manualSpotsData.numSpots = 3;
registrar.registerNewData(cySpotsData, 'cy', 'cy:Spots')
registrar.registerNewData(manualSpotsData, 'cy', 'cy:Manual')

graphTester.assertIsImmediateChild('cy', 'cy:Spots')
graphTester.assertIsImmediateChild('cy', 'cy:Manual')

improc2.tests.shouldThrowError(@() x.getData('cy'), ...
    'improc2:AmbiguousDataSpecification')

assert(getNumSpots(x.getData('cy:Spots')) == cyNumSpots)
assert(getNumSpots(x.getData('cy:Manual')) == manualSpotsData.numSpots)

assert(getNumSpots(x.getData('cy', 'improc2.interfaces.ProcessedData')) == cyNumSpots)
assert(getNumSpots(x.getData('cy', 'improc2.tests.MockManualSpotsData')) == manualSpotsData.numSpots)

%% Setting data:

modifiedCyNumSpots = 2*cyNumSpots + 1;
modifiedCySpotsData = improc2.tests.MockSpotsData(modifiedCyNumSpots);


objHolder.obj = objWithSpotsData;
assert(getNumSpots(x.getData('cy')) == cyNumSpots)
x.setData(modifiedCySpotsData, 'cy')
assert(getNumSpots(x.getData('cy')) == modifiedCyNumSpots)

objHolder.obj = objWithSpotsData;
assert(getNumSpots(x.getData('cy')) == cyNumSpots)
x.setData(modifiedCySpotsData, 'cy:Spots')
assert(getNumSpots(x.getData('cy')) == modifiedCyNumSpots)

objHolder.obj = objWithSpotsData;
assert(getNumSpots(x.getData('cy')) == cyNumSpots)
x.setData(modifiedCySpotsData, 'cy', 'improc2.tests.MockSpotsData')
assert(getNumSpots(x.getData('cy')) == modifiedCyNumSpots)

objHolder.obj = objWithSpotsData;
assert(getNumSpots(x.getData('cy')) == cyNumSpots)
x.setData(modifiedCySpotsData, 'cy', 'improc2.interfaces.SpotsProvider')
assert(getNumSpots(x.getData('cy')) == modifiedCyNumSpots)

%% Setting data: Replacement must be of the same class

objHolder.obj = objWithSpotsData;

improc2.tests.shouldThrowError(...
    @() x.setData(manualSpotsData, 'cy'), 'improc2:BadArguments')

%% Setting data: error if ambiguous

objHolder.obj = baseObj;

registrar.registerNewData(cySpotsData, 'cy', 'cy:Spots')
registrar.registerNewData(manualSpotsData, 'cy', 'cy:Manual')

objWithCySpotsAndManual = objHolder.obj;

graphTester.assertIsImmediateChild('cy', 'cy:Spots')
graphTester.assertIsImmediateChild('cy', 'cy:Manual')

improc2.tests.shouldThrowError(@() x.setData(modifiedCySpotsData, 'cy'), ...
    'improc2:AmbiguousDataSpecification')
assert(getNumSpots(x.getData('cy:Spots')) == cyNumSpots)

%% Setting data: specifying by node label and data type

objHolder.obj = objWithCySpotsAndManual;
assert(getNumSpots(x.getData('cy:Spots')) == cyNumSpots)
x.setData(modifiedCySpotsData, 'cy:Spots')
assert(getNumSpots(x.getData('cy:Spots')) == modifiedCyNumSpots)

objHolder.obj = objWithCySpotsAndManual;
assert(getNumSpots(x.getData('cy:Spots')) == cyNumSpots)
x.setData(modifiedCySpotsData, 'cy', 'improc2.tests.MockSpotsData')
assert(getNumSpots(x.getData('cy:Spots')) == modifiedCyNumSpots)

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

registrar.registerNewData(cyProcessedSpotsData, 'cy', 'cy:Spots')
registrar.registerNewData(tmrProcessedSpotsData, 'tmr', 'tmr:Spots')
registrar.registerNewData(cyProcessedFitted, 'cy', 'cy:Fitted')
registrar.registerNewData(tmrProcessedFitted, 'tmr', 'tmr:Fitted')
registrar.registerNewData(processedColocolizer, ...
    {'cy:Fitted', 'tmr:Fitted'}, 'coloc')

graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted', ...
    'tmr:Fitted', 'coloc')

% even setting data back to itself, triggers updates.
x.setData(cyProcessedSpotsData, 'cy:Spots')
graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots','tmr:Fitted')
graphTester.assertNeedUpdate('cy:Fitted', 'coloc')

x.setData(tmrProcessedSpotsData, 'tmr:Spots')
graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots')
graphTester.assertNeedUpdate('cy:Fitted', 'coloc', 'tmr:Fitted')

%% HasData:

objHolder.obj = baseObj;

objHolder.obj = objWithSpotsData;
assert(x.hasData('cy'))
assert(x.hasData('cy:Spots'))
assert(x.hasData('cy', 'improc2.tests.MockSpotsData'))
assert(x.hasData('cy', 'improc2.interfaces.SpotsProvider'))
assert(~ x.hasData('cy', 'improc2.tests.MockFittedData'))

registrar.registerNewData(improc2.tests.MockFittedData(), 'cy', 'cy:Fitted')

assert(x.hasData('cy', 'improc2.tests.MockFittedData'))
assert(~ x.hasData('tmr', 'improc2.tests.MockFittedData'))

% getting would fail due to ambiguity, but 'has' query succeeds.
assert(x.hasData('cy'))

assert(~x.hasData('somethingThatDoesNotExist'))

%% runProcessor: clears needsUpdate flag to false

objHolder.obj = objWithSpotsData;

imageProviders = dentist.utils.makeFilledChannelArray({'cy','tmr','dapi'}, ...
    @(channelName) improc2.tests.MockCroppedImageProvider());

graphTester.assertNeedUpdate('cy:Spots')
x.runProcessor(imageProviders, 'cy')
graphTester.assertDoNotNeedUpdate('cy:Spots')

%% runProcessor: automatically grabbing dependencies.

objHolder.obj = objWithFittedData;

graphTester.assertNeedUpdate('cy:Spots','cy:Fitted')
assert(getNumSpots(x.getData('cy:Spots')) == cyNumSpots)
assert(isempty(getNumSpots(x.getData('cy:Fitted'))))

x.runProcessor(imageProviders, 'cy:Spots')

graphTester.assertNeedUpdate('cy:Fitted')
graphTester.assertDoNotNeedUpdate('cy:Spots')
assert(isempty(getNumSpots(x.getData('cy:Fitted'))))

x.runProcessor(imageProviders, 'cy:Fitted')

graphTester.assertDoNotNeedUpdate('cy:Spots', 'cy:Fitted')
assert(getNumSpots(x.getData('cy:Spots')) == cyNumSpots)
assert(getNumSpots(x.getData('cy:Fitted')) == cyNumSpots)


x.runProcessor(imageProviders, 'tmr:Spots')
x.runProcessor(imageProviders, 'tmr:Fitted')

graphTester.assertDoNotNeedUpdate('cy:Spots', 'cy:Fitted', 'tmr:Spots', 'tmr:Fitted')

registrar.registerNewData(improc2.tests.MockColocolizerData(), ...
    {'cy:Fitted', 'tmr:Fitted'}, 'coloc')

graphTester.assertNeedUpdate('coloc')
colocData = x.getData('coloc');
assert(isempty(colocData.numSpotsA))
assert(isempty(colocData.numSpotsB))

x.runProcessor(imageProviders, 'coloc')

graphTester.assertDoNotNeedUpdate('coloc')
colocData = x.getData('coloc');
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
registrar.registerNewData(improc2.tests.MockColocolizerData(), ...
    {'cy:Fitted', 'tmr:Fitted'}, 'coloc')


graphTester.assertNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted', ...
    'tmr:Fitted', 'coloc')
assert(isempty(getNumSpots(x.getData('tmr:Fitted'))))
assert(isempty(getNumSpots(x.getData('cy:Fitted'))))
colocData = x.getData('coloc');
assert(isempty(colocData.numSpotsA))
assert(isempty(colocData.numSpotsB))

x.updateAllProcessedData(imageProviders)

graphTester.assertDoNotNeedUpdate('cy:Spots', 'tmr:Spots', 'cy:Fitted', ...
    'tmr:Fitted', 'coloc')

assert(getNumSpots(x.getData('tmr:Fitted')) == tmrNumSpots)
assert(getNumSpots(x.getData('cy:Fitted')) == cyNumSpots)
colocData = x.getData('coloc');
assert(colocData.numSpotsA == cyNumSpots)
assert(colocData.numSpotsB == tmrNumSpots)

%% Updating: will not update (but won't throw error) if there is a dependent

objHolder.obj = baseObj;

registrar.registerNewData(improc2.tests.MockManualSpotsData(), 'cy', 'cy:Manual')
registrar.registerNewData(tmrSpotsData, 'tmr', 'tmr:Spots')
registrar.registerNewData(improc2.tests.MockFittedData(), {'cy:Manual', 'cy'}, 'cy:FittedToManual')
registrar.registerNewData(improc2.tests.MockFittedData(), {'tmr:Spots', 'tmr'}, 'tmr:Fitted')
registrar.registerNewData(improc2.tests.MockColocolizerData(), ...
    {'cy:FittedToManual', 'tmr:Fitted'}, 'coloc')

graphTester.assertNeedUpdate('cy:Manual', 'cy:FittedToManual', ...
    'tmr:Spots', 'tmr:Fitted', 'coloc')

assert(~isa(x.getData('cy:Manual'), 'improc2.interfaces.ProcessedData'))

x.updateAllProcessedData(imageProviders)

graphTester.assertDoNotNeedUpdate('tmr:Spots', 'tmr:Fitted')
graphTester.assertNeedUpdate('cy:Manual', 'cy:FittedToManual', 'coloc')

cyManual = x.getData('cy:Manual');
cyManual.numSpots = 35;
cyManual.needsUpdate = false;
x.setData(cyManual, 'cy:Manual')

x.updateAllProcessedData(imageProviders)

graphTester.assertDoNotNeedUpdate('cy:Manual', 'cy:FittedToManual', ...
    'tmr:Spots', 'tmr:Fitted', 'coloc')


%% testing needs update when you have an unrooted node.

objHolder.obj = objWithSpotsData;

mockFactor = 3;
independentData = improc2.tests.MockNoDependentsData();
independentData.value = mockFactor;
assert(isa(independentData, 'improc2.interfaces.NodeData'))

registrar.registerNewData(independentData, {}, 'factorSource')

dependsOnBothRoots = improc2.tests.MockNeedsSpotsAndIndependentData();
assert(isa(dependsOnBothRoots, 'improc2.interfaces.ProcessedData'))

registrar.registerNewData(dependsOnBothRoots, {'cy:Spots', 'factorSource'}, 'multipliedSpots')

x.updateAllProcessedData(imageProviders)


assert(getNumSpots(x.getData('cy:Spots')) == cyNumSpots)
assert(cyNumSpots ~= 0)

expectedSpots = cyNumSpots * mockFactor;
assert(getNumSpots(x.getData('multipliedSpots')) == expectedSpots)

graphTester.assertDoNotNeedUpdate('multipliedSpots', 'factorSource')


factorSource = x.getData('factorSource');
newFactor = 56;
factorSource.value = newFactor;
x.setData(factorSource, 'factorSource');

graphTester.assertDoNotNeedUpdate('factorSource')
graphTester.assertNeedUpdate('multipliedSpots')


x.updateAllProcessedData(imageProviders)

graphTester.assertDoNotNeedUpdate('multipliedSpots', 'factorSource')

expectedSpots = cyNumSpots * newFactor;
assert(getNumSpots(x.getData('multipliedSpots')) == expectedSpots)


%% graph for wiki page

objHolder.obj = objWithSpotsData;

registrar.registerNewData(improc2.tests.MockColocolizerData(), ...
    {'cy:Spots', 'tmr:Spots'}, 'colocolization')

registrar.registerNewData(improc2.tests.MockSpotsData(0), {'dapi'}, 'nuclearMask') 

registrar.registerNewData(improc2.nodeProcs.ThresholdQCData(), ...
    {'cy:Spots'}, 'cy:theshQC')

registrar.registerNewData(improc2.nodeProcs.ThresholdQCData(), ...
    {'tmr:Spots'}, 'tmr:theshQC')

x.updateAllProcessedData(imageProviders)
