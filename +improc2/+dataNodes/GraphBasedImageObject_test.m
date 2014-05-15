improc2.tests.cleanupForTests;

x = improc2.dataNodes.GraphBasedImageObject();

assert(isa(x.annotations.isGood, 'improc2.TypeCheckedLogical'))
assert(x.annotations.isGood.value)

x.annotations.newField = 'anything';
assert(isequal(x.annotations.newField, 'anything'));

assert(isempty(x.graph))
x.graph = 'anythingWhatsoever';
assert(isequal(x.graph, 'anythingWhatsoever'));

assert(isstruct(x.metadata))

x.metadata.newField = 'alsoAnything';
assert(isequal(x.metadata.newField, 'alsoAnything'));