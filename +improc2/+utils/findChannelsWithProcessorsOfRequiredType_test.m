improc2.tests.cleanupForTests;

obj = struct();
obj.channels = struct('cy',struct(), 'tmr',struct(), ...
    'dapi', struct(), 'trans', struct());
obj.channels.cy.processor = improc2.procs.aTrousRegionalMaxProcData(); % a subclass of regionalmaxproc
obj.channels.tmr.processor = improc2.procs.RegionalMaxProcData();
obj.channels.dapi.processor = improc2.procs.DapiProcData();
obj.channels.trans.processor = improc2.procs.TransProcData();

mockObjHolder = improc2.tests.MockObjHolder();
mockObjHolder.obj = obj;

imageObjectHandle = improc2.utils.HandleToLegacyimage_object(mockObjHolder);

chans = improc2.utils.findChannelsWithProcessorsOfRequiredType(...
    imageObjectHandle, 'improc2.procs.RegionalMaxProcData');

assert(length(chans) == 2)
assert(ismember('cy', chans))
assert(ismember('tmr', chans))

chans = improc2.utils.findChannelsWithProcessorsOfRequiredType(...
    imageObjectHandle, 'bogusProcessorClassName');

assert(isempty(chans))
