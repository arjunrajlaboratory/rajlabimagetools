improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests(); cd(dirPath) % loads an image object and a dirPath

x = improc2.ManagedProcQueueRunner;
x = x.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData);
% Test insert attempt without necessary dependency in managed queue already:
try
    x = x.registerNewProcessor(improc2.tests.MinimalPostPostProcessor);
catch err
    improc2.tests.handleExpectedError(err,'improc2:DependencyNotFound');
end
x = x.registerNewProcessor(improc2.tests.MinimalPostProcessor);
x = x.registerNewProcessor(improc2.tests.MinimalPostPostProcessor);
x = x.runProcAtIndex(1, objH, 'cy');
x = x.runProcAtIndex(2);
x = x.runProcAtIndex(3);
% test access to processors
assert(isa(x.processors(3), 'improc2.tests.MinimalPostPostProcessor'))
% test consistent running
assert(x.processors(1).getNumSpots == x.processors(3).numSpots)
% test update management
assert(~x.processors(2).needsUpdate && ~x.processors(3).needsUpdate)
x.processors(1).threshold = 0.8*(x.processors(1).threshold);
assert(x.processors(2).needsUpdate && x.processors(3).needsUpdate)
% test needsUpdate reset to false after running procs using Runner.
x = x.runProcAtIndex(2);
x = x.runProcAtIndex(3);
assert(~x.processors(2).needsUpdate && ~x.processors(3).needsUpdate)
