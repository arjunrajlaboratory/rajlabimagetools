improc2.tests.cleanupForTests;

channelNames = 'tmr';
x = improc2.utils.validateAndFormatChannelNamesArgument(channelNames);
assert(isequal(x, {'tmr'}))

channelNames = {'tmr'};
x = improc2.utils.validateAndFormatChannelNamesArgument(channelNames);
assert(isequal(x, {'tmr'}))

channelNames = {'tmr', 'anythingYouWant'};
x = improc2.utils.validateAndFormatChannelNamesArgument(channelNames);
assert(isequal(x, {'tmr', 'anythingYouWant'}))

improc2.tests.shouldThrowError(...
    @() improc2.utils.validateAndFormatChannelNamesArgument({}), ...
    'improc2:BadArguments')
improc2.tests.shouldThrowError(...
    @() improc2.utils.validateAndFormatChannelNamesArgument(3), ...
    'improc2:BadArguments')
improc2.tests.shouldThrowError(...
    @() improc2.utils.validateAndFormatChannelNamesArgument({'tmr', 45}), ...
    'improc2:BadArguments')


