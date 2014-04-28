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

x = improc2.dataNodes.ProcessorRegistrarForGraphBasedImageObject(objHolder);

view(objHolder.obj.graph)

unprocessedSpotsData = improc2.tests.MockSpotsData();

x.registerNewProcessor(unprocessedSpotsData, 'cy', 'cy:SpotsData')
x.registerNewProcessor(unprocessedSpotsData, {'tmr'}, 'tmr:SpotsData')

cySpotsNode = objHolder.obj.graph.getNodeByLabel('cy:SpotsData');
assert(isa(cySpotsNode.data, 'improc2.tests.MockSpotsData'))


view(objHolder.obj.graph)