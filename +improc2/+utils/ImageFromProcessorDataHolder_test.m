improc2.tests.cleanupForTests;

im= eye(2,2);
fakeImageHoldingProcessor = improc2.tests.MockImageHolder(im);

fakeProcessorDataHolder = struct('processorData', fakeImageHoldingProcessor);

x = improc2.utils.ImageFromProcessorDataHolder(fakeProcessorDataHolder);

assert(isequal(x.getImage(), im))
