improc2.tests.cleanupForTests;

mockNavigator = improc2.tests.MockGoToNextOrPrevObj();
channelHolder = dentist.utils.ChannelSwitchCoordinator({'alexa','cy','tmr'});
channelHolder.setChannelName('alexa');


x = improc2.utils.NavigationKeyboardInterpreter(mockNavigator, channelHolder);

channelIs = @(channelName) strcmp(channelName, channelHolder.getChannelName);

assert(mockNavigator.timesGoToNext == 0)
assert(mockNavigator.timesGoToPrev == 0)
assert(channelIs('alexa'))

irrelevantSource = [];

keyPressEvent = @(key) struct('Key', key);
pressKey = @(key) x.keyPressCallBackFunc(irrelevantSource, keyPressEvent(key));

pressKey('leftarrow')
assert(mockNavigator.timesGoToPrev == 1)
pressKey('a')
assert(mockNavigator.timesGoToPrev == 2)
pressKey('A')
assert(mockNavigator.timesGoToPrev == 3)

pressKey('rightarrow')
assert(mockNavigator.timesGoToNext == 1)
pressKey('d')
assert(mockNavigator.timesGoToNext == 2)
pressKey('D')
assert(mockNavigator.timesGoToNext == 3)

assert(channelIs('alexa'))
assert(all(strcmp(channelHolder.channelNames, {'alexa', 'cy', 'tmr'})));
pressKey('e')
assert(channelIs('cy'))
pressKey('E')
assert(channelIs('tmr'))
pressKey('e')
assert(channelIs('alexa'))

pressKey('q')
assert(channelIs('tmr'))
pressKey('Q')
assert(channelIs('cy'))
pressKey('Q')
assert(channelIs('alexa'))

