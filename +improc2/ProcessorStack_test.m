improc2.tests.cleanupForTests;

x = improc2.ProcessorStack;
x = x.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData());
x = x.registerNewProcessor(improc2.procs.DapiProcData());
x = x.registerNewProcessor(improc2.procs.TransProcData());
assert(x.length() == 3)

disp(x) % inspect visually

x = x.registerNewProcessor(improc2.procs.RegionalMaxProcData);
assert(x.length() == 4)

improc2.tests.shouldThrowError(@() x.registerNewProcessor(struct()), ...
    'improc2:BadArguments');

assert( isa( x.getProcessorByPos(1), 'improc2.procs.aTrousRegionalMaxProcData'))
assert( isa( x.getProcessorByPos(3), 'improc2.procs.TransProcData'))
assert( isa( x.getProcessorByPos(4), 'improc2.procs.RegionalMaxProcData'))
% test set proc:
x = x.setProcessorByPos(improc2.procs.RegionalMaxProcData, 4);
assert( isa( x.getProcessorByPos(4), 'improc2.procs.RegionalMaxProcData'))

improc2.tests.shouldThrowError(@() x.setProcessorByPos(improc2.procs.DapiProcData, 4), ...
    'improc2:ProcessorReplaceConflict');

assert(x.indexFromClassName('improc2.procs.DapiProcData') == 2)
assert(x.indexFromClassName('improc2.SpotFindingInterface') == 1)
assert(x.indexFromClassName('improc2.SpotFindingInterface','last') == 4)
assert(x.indexFromClassName('improc2.SpotFindingInterface','first',2,4) == 4)

assert(x.hasProcessorData('improc2.SpotFindingInterface'))
assert(x.hasProcessorData('improc2.procs.RegionalMaxProcData'))
assert(x.hasProcessorData('improc2.procs.DapiProcData'))
assert(~x.hasProcessorData('improc2.PostProcessor'))
improc2.tests.shouldThrowError(...
    @() x.indexFromClassName('improc2.PostProcessor'), 'improc2:ProcNotFound');

assert(isa(x(3), 'improc2.procs.TransProcData'))

x(3) = improc2.procs.TransProcData();
% We are doing the following tests without having run the RegionalMaxProc,
% so we'll spare you the warnings which you would normally get when trying
% to get threshold from them:
s = warning('off','improc2:GetFromNeedingRunOrUpdate');
try
    x(4).threshold = 0;
    assert(x(4).threshold == 0)
    x(4).threshold = 1;
    assert(x(4).threshold == 1)
    warning(s);
catch err
    warning(s);
    throw(err)
end
