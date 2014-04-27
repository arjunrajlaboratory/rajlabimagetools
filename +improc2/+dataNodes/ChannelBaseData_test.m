improc2.tests.cleanupForTests;

x = improc2.dataNodes.ChannelBaseData();

assert(isempty(x.channelName))
assert(isempty(x.fileName))
assert(isempty(x.dirPath))

x.channelName = 'cy';
x.fileName = 'cy003.tiff';
x.dirPath = '~/tests/';

assert(isequal(x.channelName, 'cy'))
assert(isequal(x.fileName, 'cy003.tiff'))
assert(isequal(x.dirPath, '~/tests/'))
