dentist.tests.cleanupForTests;

array = dentist.utils.PositionAndChannelArray(3, 3, {'tmr','dapi','cy'});
array = array.setByChannelByPosition(4,'dapi',2,3);
assert(array.getByChannelByPosition('dapi',2,3) == 4);

chanArray = dentist.utils.ChannelArray({'tmr','dapi','cy'});
chanArray = chanArray.setByChannelName(5, 'tmr');
assert(chanArray.getByChannelName('tmr') == 5);

array = array.setByPosition(chanArray,1,2);

assert(array.getByChannelByPosition('tmr',1,2) == 5)


%% aggregation test

x = dentist.utils.PositionAndChannelArray(2,2,{'tmr','cy'});

x = x.setByChannelByPosition(10, 'tmr', 1, 1);
x = x.setByChannelByPosition(11, 'tmr', 1, 2);
x = x.setByChannelByPosition(12, 'tmr', 2, 1);
x = x.setByChannelByPosition(13, 'tmr', 2, 2);
x = x.setByChannelByPosition(20, 'cy', 1, 1);
x = x.setByChannelByPosition(21, 'cy', 1, 2);
x = x.setByChannelByPosition(22, 'cy', 2, 1);
x = x.setByChannelByPosition(23, 'cy', 2, 2);
agg = x.aggregateAllPositions(@(a,b) a + b);

assert(agg.getByChannelName('tmr') == 10+11+12+13)
assert(agg.getByChannelName('cy') == 20+21+22+23)
