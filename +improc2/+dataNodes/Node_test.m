improc2.tests.cleanupForTests;

x = improc2.dataNodes.Node();

assert(isempty(x.label))
assert(isempty(x.data))
assert(isempty(x.dependencyNodeNumbers))
assert(isnan(x.number))

x.label = 'testNode';
x.data = 'anything';
x.number = 5;
x.dependencyNodeNumbers = [2,4];

assert(isequal(x.label, 'testNode'))
assert(isequal(x.data, 'anything'))
assert(isequal(x.number, 5))
assert(isequal(x.dependencyNodeNumbers, [2, 4]))