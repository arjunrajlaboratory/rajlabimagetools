improc2.tests.cleanupForTests;

obj = struct();

obj.channels = struct('cy',struct(), 'tmr',struct(), 'alexa', struct());
obj.channels.cy.processor = 'fakeCyProc';
obj.channels.cy.filename = 'cyFileName.ext';
obj.channels.tmr.processor = 'fakeTmrProc';
obj.channels.alexa.processor = [];
obj.object_mask = struct();
obj.object_mask.mask = 'fakeCroppedMask';
obj.object_mask.imfilemask = 'fakeFullMask';
obj.object_mask.boundingbox = 'fakeBoundingBox';
obj.metadata = 'fakeMetadata';
obj.filenames.path = 'somePath';

mockObjHolder = improc2.tests.MockObjHolder();
mockObjHolder.obj = obj;

x = improc2.utils.HandleToLegacyimage_object(mockObjHolder);

assert(strcmp(x.getMetaData(), 'fakeMetadata'))
x.setMetaData('anotherFakeMetaData')
assert(strcmp(x.getMetaData(), 'anotherFakeMetaData'))

assert(strcmp(x.getMask(), 'fakeFullMask'))
assert(strcmp(x.getCroppedMask(), 'fakeCroppedMask'))
assert(strcmp(x.getBoundingBox(), 'fakeBoundingBox'))
assert(all(ismember(x.channelNames, fields(obj.channels))))
assert(strcmp(x.getData('cy'), 'fakeCyProc'))
assert(strcmp(x.getData('tmr'), 'fakeTmrProc'))

fakeProcessorClassName = 'char';
assert(x.hasData('cy', fakeProcessorClassName))
assert(x.hasData('tmr', fakeProcessorClassName))
assert(~ x.hasData('cy', 'numeric'))
assert(~ x.hasData('alexa'))

assert(strcmp(mockObjHolder.obj.channels.cy.processor, 'fakeCyProc'))
x.setData('modifiedCyProc', 'cy')
assert(strcmp(mockObjHolder.obj.channels.cy.processor, 'modifiedCyProc'))

assert(strcmp(mockObjHolder.obj.channels.tmr.processor, 'fakeTmrProc'))
x.setData('modifiedTmrProc', 'tmr')
assert(strcmp(mockObjHolder.obj.channels.tmr.processor, 'modifiedTmrProc'))

assert(strcmp(x.getImageFileName('cy'), 'cyFileName.ext'))
assert(strcmp(x.getImageDirPath(), 'somePath'))
