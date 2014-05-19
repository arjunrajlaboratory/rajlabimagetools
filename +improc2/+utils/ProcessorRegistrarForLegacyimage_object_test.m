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
assert(x.hasData('cy', fakeProcessorClassName))
assert(x.hasData('tmr', fakeProcessorClassName))
assert(~ x.hasData('cy', 'numeric'))
assert(~ x.hasData('alexa'))


improc2.tests.shouldThrowError(@() ...
    x.registerNewData(improc2.nodeProcs.aTrousRegionalMaxProcessedData(), 'cy'), ...
    'improc2:NoLegacySupport')
