improc2.tests.cleanupForTests;

mask = [0 1 1 1 1; 0 1 1 1 0; 0 0 0 0 0];
dirPath = '~/tests/';
channelInfo.channelNames = {'cy', 'tmr', 'dapi'};
channelInfo.fileNames = {'cy002.tiff', 'tmr002.tiff', 'dapi002.tiff'};

graph = improc2.dataNodes.buildMinimalImageObjectGraph(mask, dirPath, channelInfo);

obj = improc2.dataNodes.GraphBasedImageObject();
obj.graph = graph;

objHolder = improc2.utils.ObjectHolder();
objHolder.obj = obj;

x = improc2.dataNodes.ProcessorRegistrarForGraphBasedImageObject(objHolder);