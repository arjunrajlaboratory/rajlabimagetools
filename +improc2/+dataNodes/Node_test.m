improc2.tests.cleanupForTests;

x = improc2.dataNodes.Node();

assert(isempty(x.label))
assert(isempty(x.data))
assert(isempty(x.dependencyNodeLabels))
assert(isempty(x.childNodeLabels))

notAString = 34.2;
improc2.tests.shouldThrowError(@() setfield(x, 'label', notAString))
x.label = 'testNode';
x.data = 'anything';
x.dependencyNodeLabels = {'parent1', 'parent2'};
x.childNodeLabels = {'child1'};

assert(isequal(x.label, 'testNode'))
assert(isequal(x.data, 'anything'))
assert(isequal(x.dependencyNodeLabels, {'parent1', 'parent2'}))
assert(isequal(x.childNodeLabels, {'child1'}));