improc2.tests.cleanupForTests;

mask = [0 1; 0 0];
dirPath = '~/tests/';
channelInfo.channelNames = {'cy', 'tmr', 'dapi'};
channelInfo.fileNames = {'cy002.tiff', 'tmr002.tiff', 'dapi002.tiff'};

x = improc2.dataNodes.buildMinimalImageObjectGraph(mask, dirPath, channelInfo);

assert(numberOfNodes(x) == 4);
assert(isequal( x.nodes{1}.label, 'imageObject'))
assert(isequal( x.nodes{2}.label, 'cy'))
assert(isequal( x.nodes{3}.label, 'tmr'))
assert(isequal( x.nodes{4}.label, 'dapi'))

assert(isequal( x.nodes{2}.dependencyNodeLabels, {'imageObject'}))
assert(isequal( x.nodes{3}.dependencyNodeLabels, {'imageObject'}))
assert(isequal( x.nodes{4}.dependencyNodeLabels, {'imageObject'}))

assert(isa(x.nodes{1}.data, 'improc2.dataNodes.ImageObjectBaseData'))
assert(isa(x.nodes{3}.data, 'improc2.dataNodes.ChannelStackContainer'))

assert(isequal(x.nodes{1}.data.imageFileMask, mask))
assert(isequal(x.nodes{3}.data.channelName, 'tmr'))
assert(isequal(x.nodes{3}.data.fileName, 'tmr002.tiff'))
assert(isequal(x.nodes{3}.data.dirPath, '~/tests/'))

view(x)