dentist.tests.cleanupForTests;

t = dentist.utils.ChannelArray({'cy','tmr'});
t = t.setByChannelName(50, 'cy');
t = t.setByChannelName(100, 'tmr');

x = dentist.utils.ThresholdsHolder(t);

assert(x.getThreshold('cy') == 50)
assert(x.getThreshold('tmr') == 100)

x.setThreshold(300, 'cy')

assert(x.getThreshold('cy') == 300)
assert(x.getThreshold('tmr') == 100)

a = dentist.tests.MockDrawCountingDisplayer();
b = dentist.tests.MockDrawCountingDisplayer();

x.addActionOnUpdate(a, @draw);
x.addActionOnUpdate(b, @draw);

assert(a.timesDrawn == 0)
assert(b.timesDrawn == 0)

x.setThreshold(30, 'tmr')

assert(x.getThreshold('cy') == 300)
assert(x.getThreshold('tmr') == 30)

assert(a.timesDrawn == 1)
assert(b.timesDrawn == 1)
