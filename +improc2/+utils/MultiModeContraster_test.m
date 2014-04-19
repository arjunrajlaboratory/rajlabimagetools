improc2.tests.cleanupForTests;

a = improc2.tests.MockContraster(10);
b = improc2.tests.MockContraster(20);
c = improc2.tests.MockContraster(30);

contrasters = struct('one', a, 'two', b, 'three', c);
x = improc2.utils.MultiModeContraster(contrasters);


assert(x.contrast() == 10)
x.setMode('two')
assert(x.contrast() == 20)
x.setMode('three')
assert(x.contrast() == 30)

improc2.tests.shouldThrowError(@() x.setMode('unknown'), 'improc2:BadArguments')
