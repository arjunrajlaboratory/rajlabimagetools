dentist.tests.cleanupForTests;
channelNames = {'cy','tmr','dapi'};
myArray = dentist.utils.ChannelArray(channelNames);

assert(all(strcmp(myArray.channelNames, channelNames)))

myArray = myArray.setByChannelName(5,'cy');
assert(myArray.getByChannelName('cy') == 5);

x = dentist.utils.ChannelArray({'cy', 'tmr', 'dapi'});
x = x.setByChannelName(zeros(2,3), 'cy');
x = x.setByChannelName(zeros(1,5), 'tmr');
x = x.setByChannelName(zeros(20,15), 'dapi');

[sz1, sz2] = x.applyForEachChannel(@size);
assert(sz1.getByChannelName('cy') == 2)
assert(sz1.getByChannelName('tmr') == 1)
assert(sz1.getByChannelName('dapi') == 20)
assert(sz2.getByChannelName('cy') == 3)
assert(sz2.getByChannelName('tmr') == 5)
assert(sz2.getByChannelName('dapi') == 15)
