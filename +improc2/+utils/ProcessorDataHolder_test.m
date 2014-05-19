improc2.tests.cleanupForTests;

obj = struct();
obj.channels = struct('cy',struct(), 'tmr',struct(), ...
    'dapi', struct(), 'trans', struct());
obj.channels.cy.processor = struct('name', 'cy');
obj.channels.tmr.processor = struct('name', 'tmr');
obj.channels.dapi.processor = struct('name', 'dapi');
obj.channels.trans.processor = struct('name', 'trans');

mockObjHolder = improc2.tests.MockObjHolder();
mockObjHolder.obj = obj;

imageObjectHandle = improc2.utils.HandleToLegacyimage_object(mockObjHolder);

chanHolder = dentist.utils.ChannelSwitchCoordinator({'cy', 'tmr', 'dapi', 'trans'});

x = improc2.utils.ProcessorDataHolder(imageObjectHandle, chanHolder, 'struct');

assert(strcmp(x.processorData.name, 'cy'))

chanHolder.setChannelName('dapi')
assert(strcmp(x.processorData.name, 'dapi'))

x.processorData.somethingElse = 1;

dapiproc = imageObjectHandle.getData('dapi');
assert(dapiproc.somethingElse == 1)
