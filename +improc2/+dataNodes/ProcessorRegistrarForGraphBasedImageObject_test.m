improc2.tests.cleanupForTests;

mask = 0;
dirPath = '';
channelInfo.channelNames = {'cy', 'tmr', 'dapi'};
channelInfo.fileNames = {'', '', ''};

graph = improc2.dataNodes.buildMinimalImageObjectGraph(mask, dirPath, channelInfo);

obj = improc2.dataNodes.GraphBasedImageObject();
obj.graph = graph;
objHolder = improc2.utils.ObjectHolder();
objHolder.obj = obj;

tester = improc2.tests.DataNodeGraphTester(objHolder);

x = improc2.dataNodes.ProcessorRegistrarForGraphBasedImageObject(objHolder);

unprocessedSpotsData = improc2.tests.MockSpotsData();

x.registerNewProcessor(unprocessedSpotsData, 'cy', 'cy:SpotsData')
x.registerNewProcessor(unprocessedSpotsData, {'tmr'}, 'tmr:SpotsData')

tester.assertIsImmediateChild('cy', 'cy:SpotsData')
tester.assertIsImmediateChild('tmr', 'tmr:SpotsData')
assert(isa(tester.getNodeData('cy:SpotsData'), 'improc2.tests.MockSpotsData'))


