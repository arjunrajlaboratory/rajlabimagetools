improc2.tests.cleanupForTests;

mask = 0;
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

x.registerNewProcessor(unprocessedSpotsData, 'cy', 'cy:SpotsData')
x.registerNewProcessor(unprocessedSpotsData, {'tmr'}, 'tmr:SpotsData')

tester.assertIsImmediateChild('cy', 'cy:SpotsData')
tester.assertIsImmediateChild('tmr', 'tmr:SpotsData')
assert(isa(tester.getNodeData('cy:SpotsData'), 'improc2.tests.MockSpotsData'))

objWithSpotsData = objHolder.obj;

%%
objHolder.obj = objWithSpotsData;
unprocessedFittedData = improc2.tests.MockFittedData();

x.registerNewProcessor(unprocessedFittedData, {'cy:SpotsData', 'cy'}, 'cy:FittedData')

tester.assertIsImmediateChild('cy', 'cy:FittedData')
tester.assertIsImmediateChild('cy:SpotsData', 'cy:FittedData')

%%
objHolder.obj = objWithSpotsData;

x.registerNewProcessor(unprocessedFittedData, {'cy'}, 'cy:FittedData')

tester.assertIsImmediateChild('cy', 'cy:FittedData')
tester.assertIsImmediateChild('cy:SpotsData', 'cy:FittedData')

%%
objHolder.obj = objWithSpotsData;

x.registerNewProcessor(unprocessedFittedData, 'cy', 'cy:FittedData')

tester.assertIsImmediateChild('cy', 'cy:FittedData')
tester.assertIsImmediateChild('cy:SpotsData', 'cy:FittedData')

%%

objHolder.obj = objWithSpotsData;

improc2.tests.shouldThrowError(...
    @() x.registerNewProcessor(unprocessedFittedData, ...
    {'cy:SpotsData','tmr:SpotsData'}, 'cy:FittedData'), ...
    'improc2:DependencyNotFound')

%%

objHolder.obj = objWithSpotsData;

x.registerNewProcessor(unprocessedFittedData, 'cy', 'cy:FittedData')
x.registerNewProcessor(unprocessedFittedData, 'tmr', 'tmr:FittedData')

objWithFittedData = objHolder.obj;
unprocessedColocolizerData = improc2.tests.MockColocolizerData();

%%

objHolder.obj = objWithFittedData;

x.registerNewProcessor(unprocessedColocolizerData, ...
    {'cy:SpotsData', 'tmr:SpotsData'}, 'Colocolizer')

tester.assertIsImmediateChild('cy:SpotsData', 'Colocolizer')
tester.assertIsImmediateChild('tmr:SpotsData', 'Colocolizer')

%%

objHolder.obj = objWithFittedData;

x.registerNewProcessor(unprocessedColocolizerData, ...
    {'cy:FittedData', 'tmr:FittedData'}, 'Colocolizer')

tester.assertIsImmediateChild('cy:FittedData', 'Colocolizer')
tester.assertIsImmediateChild('tmr:FittedData', 'Colocolizer')

%%

objHolder.obj = objWithFittedData;

x.registerNewProcessor(unprocessedColocolizerData, ...
    {'cy:SpotsData', 'tmr:FittedData'}, 'Colocolizer')

tester.assertIsImmediateChild('cy:SpotsData', 'Colocolizer')
tester.assertIsImmediateChild('tmr:FittedData', 'Colocolizer')

%%
objHolder.obj = objWithFittedData;

improc2.tests.shouldThrowError( ...
    @() x.registerNewProcessor(unprocessedColocolizerData, ...
    {'cy:SpotsData', 'tmr'}, 'Colocolizer'), ...
    'improc2:AmbiguousDependencySpecification')

%%

objHolder.obj = objWithFittedData;

improc2.tests.shouldThrowError( ...
    @() x.registerNewProcessor(unprocessedColocolizerData, ...
    {'cy:SpotsData', 'cy:SpotsData'}, 'Colocolizer'), ...
    'improc2:NonUniqueDependencies')

%%

objHolder.obj = baseObj;

x.registerNewProcessor(unprocessedSpotsData, {'cy'}, 'cy:SpotsData')
x.registerNewProcessor(unprocessedSpotsData, {'cy'}, 'cy:SpotsData2')

tester.assertIsImmediateChild('cy', 'cy:SpotsData')
tester.assertIsImmediateChild('cy', 'cy:SpotsData2')
