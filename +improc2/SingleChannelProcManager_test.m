improc2.tests.cleanupForTests;

[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests(); cd(dirPath) % loads an image object and a dirPath
x = improc2.SingleChannelProcManager('cy');
x = x.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData);
x = x.registerNewProcessor(improc2.tests.MinimalPostProcessor);
x = x.registerNewProcessor(improc2.tests.MinimalPostPostProcessor);
assert(~x.processors(1).isProcessed && ~x.processors(2).isProcessed && ...
    ~x.processors(3).isProcessed);
% Demonstrate processor running using just image object.
x = x.runAllUsingImgObjHandle(objH);
assert(x.processors(1).isProcessed && x.processors(2).isProcessed && ...
    x.processors(3).isProcessed);
assert(~x.processors(2).needsUpdate && ~x.processors(3).needsUpdate)
assert(x.processors(1).getNumSpots == x.processors(3).numSpots)
% Demonstrate updating:
x.processors(1).threshold = 0.8 * (x.processors(1).threshold);
assert(x.processors(2).needsUpdate && x.processors(3).needsUpdate)
x = x.updateAllUsingImgObjHandle(objH);
assert(~x.processors(2).needsUpdate && ~x.processors(3).needsUpdate)
assert(x.processors(1).getNumSpots == x.processors(3).numSpots)
% Test access to processor.
assert(isa(x.processor, 'improc2.procs.aTrousRegionalMaxProcData'))
assert(x.processor.getNumSpots == x.processors(3).numSpots)
x.processor.threshold = 0.9 * (x.processor.threshold);
assert(x.processors(2).needsUpdate && x.processors(3).needsUpdate)
