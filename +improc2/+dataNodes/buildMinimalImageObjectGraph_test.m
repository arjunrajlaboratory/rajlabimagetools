improc2.tests.cleanupForTests;

mask = [0 1; 0 0];
dirPath = '~/tests/';
channelInfo.channelNames = {'cy', 'tmr', 'dapi'};
channelInfo.fileNames = {'cy002.tiff', 'tmr002.tiff', 'dapi002.tiff'};

x = improc2.dataNodes.buildMinimalImageObjectGraph(mask, dirPath, channelInfo);

assert(length(x) == 4);
assert(isequal( x.nodes{1}.label, 'image object'))
assert(isequal( x.nodes{2}.label, 'cy'))
assert(isequal( x.nodes{3}.label, 'tmr'))
assert(isequal( x.nodes{4}.label, 'dapi'))

assert(isequal( x.nodes{2}.dependencyNodeNumbers, 1))
assert(isequal( x.nodes{3}.dependencyNodeNumbers, 1))
assert(isequal( x.nodes{4}.dependencyNodeNumbers, 1))

assert(isa(x.nodes{1}.data, 'improc2.dataNodes.ImageObjectBaseData'))
assert(isa(x.nodes{3}.data, 'improc2.dataNodes.ChannelBaseData'))

assert(isequal(x.nodes{1}.data.imageFileMask, mask))
assert(isequal(x.nodes{1}.data.channelNames, {'cy','tmr','dapi'}))
assert(isequal(x.nodes{3}.data.channelName, 'tmr'))
assert(isequal(x.nodes{3}.data.fileName, 'tmr002.tiff'))
assert(isequal(x.nodes{3}.data.dirPath, '~/tests/'))