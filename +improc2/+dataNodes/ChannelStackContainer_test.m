improc2.tests.cleanupForTests;

x = improc2.dataNodes.ChannelStackContainer();

assert(isempty(x.channelName))
assert(isempty(x.fileName))
assert(isempty(x.dirPath))
assert(isempty(x.croppedImage))
assert(isempty(x.croppedMask))

x.channelName = 'cy';
x.fileName = 'cy003.tiff';
x.dirPath = '~/tests/';
x.croppedImage = [1 2; 40 50];
x.croppedMask = [0 1; 1 1];

assert(isequal(x.channelName, 'cy'))
assert(isequal(x.fileName, 'cy003.tiff'))
assert(isequal(x.dirPath, '~/tests/'))
assert(isequal(x.croppedImage, [1 2; 40 50]))
assert(isequal(x.croppedMask, [0 1; 1 1]))