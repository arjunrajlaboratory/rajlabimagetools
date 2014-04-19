improc2.tests.cleanupForTests;

obj = struct();

obj.channels = struct('cy',struct(), 'tmr',struct(), 'alexa', struct());
obj.channels.cy.processor = 'fakeCyProc';
obj.channels.tmr.processor = 'fakeTmrProc';
obj.channels.alexa.processor = [];
obj.object_mask = struct();
obj.object_mask.mask = 'fakeCroppedMask';
obj.object_mask.imfilemask = 'fakeFullMask';
obj.object_mask.boundingbox = 'fakeBoundingBox';
obj.metadata = 'fakeMetadata';

mockObjHolder = improc2.tests.MockObjHolder();
mockObjHolder.obj = obj;

x = improc2.utils.ProcessorRegistrarForLegacyimage_object(mockObjHolder);

fakeProcessorClassName = 'char';
assert(x.hasProcessorData('cy', fakeProcessorClassName))
assert(x.hasProcessorData('tmr', fakeProcessorClassName))
assert(~ x.hasProcessorData('cy', 'numeric'))
assert(~ x.hasProcessorData('alexa'))


improc2.tests.shouldThrowError(@() ...
    x.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData(), 'cy'), ...
    'improc2:NoLegacySupport')
