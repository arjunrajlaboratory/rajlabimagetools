improc2.tests.cleanupForTests;

obj = struct();

obj.channels = struct('cy',struct(), 'tmr',struct(), ...
    'dapi', struct(), 'trans', struct());
obj.channels.cy.processor = 'fakeCyProc';
obj.channels.tmr.processor = 'fakeTmrProc';
notAString = rand(1);
obj.channels.dapi.processor = notAString;
obj.channels.trans.processor = notAString;
obj.object_mask = 'fakeMask';
obj.metadata = 'fakeMetadata';

mockObjHolder = improc2.tests.MockObjHolder();
mockObjHolder.obj = obj;

imageObjectController = improc2.utils.HandleToLegacyimage_object(mockObjHolder);

x = improc2.utils.ChannelsWithProcessorNavigator(imageObjectController, 'char');
assert(length(x.channelNames) == 2)
assert(all(ismember(x.channelNames, {'cy', 'tmr'})))

x.goToChannel('cy')
assert(strcmp(x.processor, imageObjectController.getProcessorData('cy')))
x.processor = 'modifiedCyProc';
assert(strcmp('modifiedCyProc', imageObjectController.getProcessorData('cy')))

x.goToChannel('tmr')
assert(strcmp(x.processor, imageObjectController.getProcessorData('tmr')))
x.processor = 'modifiedTmrProc';
assert(strcmp('modifiedTmrProc', imageObjectController.getProcessorData('tmr')))

improc2.tests.shouldThrowError(@() x.goToChannel('dapi'), ...
    'improc2:ChannelNotFound')

tryToMakeWhenThereIsNoSuchProcessor = @() ...
    improc2.utils.ChannelsWithProcessorNavigator(...
    imageObjectController, 'thereIsNoProcessorOfThisType');
improc2.tests.shouldThrowError(tryToMakeWhenThereIsNoSuchProcessor, ...
    'improc2:ProcessorNotFound')
