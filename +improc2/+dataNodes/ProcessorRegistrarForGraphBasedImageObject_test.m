improc2.tests.cleanupForTests;

mask = [0 1 1 1 1; 0 1 1 1 0; 0 0 0 0 0];
dirPath = '';
channelInfo.channelNames = {'cy', 'tmr', 'dapi'};
channelInfo.fileNames = {'', '', ''};

graph = improc2.dataNodes.buildMinimalImageObjectGraph(mask, dirPath, channelInfo);

baseObj = improc2.dataNodes.GraphBasedImageObject();
baseObj.graph = graph;
objHolder = improc2.utils.ObjectHolder();
objHolder.obj = baseObj;

tester = improc2.tests.DataNodeGraphTester(objHolder);

x = improc2.dataNodes.ProcessorRegistrarForGraphBasedImageObject(objHolder);

unprocessedSpotsData = improc2.tests.MockSpotsData();

x.registerNewData(unprocessedSpotsData, 'cy', 'cy:SpotsData')
x.registerNewData(unprocessedSpotsData, {'tmr'}, 'tmr:SpotsData')

tester.assertIsImmediateChild('cy', 'cy:SpotsData')
tester.assertIsImmediateChild('tmr', 'tmr:SpotsData')
assert(isa(tester.getNodeData('cy:SpotsData'), 'improc2.tests.MockSpotsData'))

objWithSpotsData = objHolder.obj;

%%
objHolder.obj = objWithSpotsData;
unprocessedFittedData = improc2.tests.MockFittedData();

x.registerNewData(unprocessedFittedData, {'cy:SpotsData', 'cy'}, 'cy:FittedData')

tester.assertIsImmediateChild('cy', 'cy:FittedData')
tester.assertIsImmediateChild('cy:SpotsData', 'cy:FittedData')

%%
objHolder.obj = objWithSpotsData;

x.registerNewData(unprocessedFittedData, {'cy'}, 'cy:FittedData')

tester.assertIsImmediateChild('cy', 'cy:FittedData')
tester.assertIsImmediateChild('cy:SpotsData', 'cy:FittedData')

%%
objHolder.obj = objWithSpotsData;

x.registerNewData(unprocessedFittedData, 'cy', 'cy:FittedData')

tester.assertIsImmediateChild('cy', 'cy:FittedData')
tester.assertIsImmediateChild('cy:SpotsData', 'cy:FittedData')

%%

objHolder.obj = objWithSpotsData;

improc2.tests.shouldThrowError(...
    @() x.registerNewData(unprocessedFittedData, ...
    {'cy:SpotsData','tmr:SpotsData'}, 'cy:FittedData'), ...
    'improc2:DependencyNotFound')

%%

objHolder.obj = objWithSpotsData;

x.registerNewData(unprocessedFittedData, 'cy', 'cy:FittedData')
x.registerNewData(unprocessedFittedData, 'tmr', 'tmr:FittedData')

objWithFittedData = objHolder.obj;
unprocessedColocolizerData = improc2.tests.MockColocolizerData();

%%

objHolder.obj = objWithFittedData;

x.registerNewData(unprocessedColocolizerData, ...
    {'cy:SpotsData', 'tmr:SpotsData'}, 'Colocolizer')

tester.assertIsImmediateChild('cy:SpotsData', 'Colocolizer')
tester.assertIsImmediateChild('tmr:SpotsData', 'Colocolizer')

%%

objHolder.obj = objWithFittedData;

x.registerNewData(unprocessedColocolizerData, ...
    {'cy:FittedData', 'tmr:FittedData'}, 'Colocolizer')

tester.assertIsImmediateChild('cy:FittedData', 'Colocolizer')
tester.assertIsImmediateChild('tmr:FittedData', 'Colocolizer')

%%

objHolder.obj = objWithFittedData;

x.registerNewData(unprocessedColocolizerData, ...
    {'cy:SpotsData', 'tmr:FittedData'}, 'Colocolizer')

tester.assertIsImmediateChild('cy:SpotsData', 'Colocolizer')
tester.assertIsImmediateChild('tmr:FittedData', 'Colocolizer')

%%
objHolder.obj = objWithFittedData;

improc2.tests.shouldThrowError( ...
    @() x.registerNewData(unprocessedColocolizerData, ...
    {'cy:SpotsData', 'tmr'}, 'Colocolizer'), ...
    'improc2:AmbiguousDependencySpecification')

%%

objHolder.obj = objWithFittedData;

improc2.tests.shouldThrowError( ...
    @() x.registerNewData(unprocessedColocolizerData, ...
    {'cy:SpotsData', 'cy:SpotsData'}, 'Colocolizer'), ...
    'improc2:NonUniqueDependencies')

%%

objHolder.obj = baseObj;

x.registerNewData(unprocessedSpotsData, {'cy'}, 'cy:SpotsData')
x.registerNewData(unprocessedSpotsData, {'cy'}, 'cy:SpotsData2')

tester.assertIsImmediateChild('cy', 'cy:SpotsData')
tester.assertIsImmediateChild('cy', 'cy:SpotsData2')


improc2.tests.shouldThrowError( ...
    @() x.registerNewData(unprocessedFittedData, ...
    {'cy'}, 'FittedSpots'), ...
    'improc2:AmbiguousDependencySpecification')


%% Can also register NodeData that is not ProcessedData

objHolder.obj = baseObj;

manualSpotsData = improc2.tests.MockManualSpotsData();
assert(~isa(manualSpotsData, 'improc2.interfaces.ProcessedData'))
assert(isa(manualSpotsData, 'improc2.interfaces.NodeData'))

x.registerNewData(manualSpotsData, {'cy'}, 'cy:ManualSpots')
tester.assertIsImmediateChild('cy', 'cy:ManualSpots')

%% Adding a node that does not depend on anything else. and a node that depends on it.

objHolder.obj = objWithSpotsData;

mockValue = 56;
independentData = improc2.tests.MockNoDependentsData();
independentData.value = mockValue;
assert(isa(independentData, 'improc2.interfaces.NodeData'))

x.registerNewData(independentData, {}, 'standalone')

data = tester.getNodeData('standalone');
assert(data.value == mockValue)

dependsOnBothRoots = improc2.tests.MockNeedsSpotsAndIndependentData();
assert(isa(dependsOnBothRoots, 'improc2.interfaces.ProcessedData'))

x.registerNewData(dependsOnBothRoots, {'cy:SpotsData', 'standalone'}, 'multipliedSpots')

tester.assertIsImmediateChild('cy:SpotsData', 'multipliedSpots')
tester.assertIsImmediateChild('standalone', 'multipliedSpots')
