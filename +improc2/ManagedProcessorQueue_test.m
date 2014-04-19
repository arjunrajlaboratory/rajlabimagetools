improc2.tests.cleanupForTests;

[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests(); cd(dirPath) % loads an image object and a dirPath
x = improc2.ManagedProcessorQueue;
proc = improc2.procs.aTrousRegionalMaxProcData;
proc = proc.run(objH,'cy');
x = x.registerNewProcessor(proc);
% Test insert attempt without necessary dependency in queue already:
try
    x = x.registerNewProcessor(improc2.tests.MinimalPostPostProcessor);
catch err
    improc2.tests.handleExpectedError(err,'improc2:DependencyNotFound');
end
% Add a post processor
pproc = improc2.tests.MinimalPostProcessor;
pproc = pproc.run(proc);
x = x.registerNewProcessor(pproc);
% Add another processor and two post processors after it
proc = improc2.procs.RegionalMaxProcData;
proc = proc.run(objH, 'cy');
pproc = improc2.tests.MinimalPostProcessor;
pproc = pproc.run(proc);
ppproc = improc2.tests.MinimalPostPostProcessor;
ppproc = ppproc.run(pproc);
x = x.registerNewProcessor(proc);
x = x.registerNewProcessor(pproc);
x = x.registerNewProcessor(ppproc);

% Test of ability to get procs necessary to run.
assert(isempty(x.getProcsNecessaryToRun(3)))

procscell = x.getProcsNecessaryToRun(4);
assert(length(procscell) == 1)
assert(strcmp(class(procscell{1}), 'improc2.procs.RegionalMaxProcData'))

procscell = x.getProcsNecessaryToRun(5);
assert( length(procscell) == 1)
assert( isa(procscell{1}, 'improc2.tests.MinimalPostProcessor'))

% Test that all and only all dependent processors are tagged for updating.
assert(~x(2).needsUpdate && ~x(4).needsUpdate && ~x(5).needsUpdate)
x(1).threshold = 0.8 * (x(1).threshold);
assert(x(2).needsUpdate && ~x(4).needsUpdate && ~x(5).needsUpdate)
x(3).threshold = 0.8 * (x(3).threshold);
assert(x(2).needsUpdate && x(4).needsUpdate && x(5).needsUpdate)
