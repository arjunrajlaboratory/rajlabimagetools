improc2.tests.cleanupForTests;

x = improc2.procs.ProcessorData();
assert(~x.isProcessed)
y = run(x);
assert(y.isProcessed)
