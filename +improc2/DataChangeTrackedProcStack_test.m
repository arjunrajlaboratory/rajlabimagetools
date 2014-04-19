improc2.tests.cleanupForTests;

x = improc2.DataChangeTrackedProcStack;
assert(isempty(x.dataHasChanged))
% Show that data has changed becomes false upon insertion.
proc = improc2.procs.TransProcData;
proc = proc.run(spiral(30), true(30));
assert(proc.dataHasChanged)
x = x.registerNewProcessor(proc);
assert(~x(1).dataHasChanged)

% Show that data change status is passed to stack and removed from the
% processor.
x = x.registerNewProcessor(improc2.procs.TransProcData);
x = x.setDataHasChangedToFalse;
assert(all(~x.dataHasChanged))

x(2) = x(2).run(spiral(30), true(30));
assert(~x.dataHasChanged(1) && x.dataHasChanged(2))
assert(~x(2).dataHasChanged)
