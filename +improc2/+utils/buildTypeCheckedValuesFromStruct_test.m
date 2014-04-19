improc2.tests.cleanupForTests;

structOfThings = struct();

structOfThings.isGood = true;
structOfThings.cellType = {'crl', 'hela'};
structOfThings.notes = 'empty';
structOfThings.numNeighbors = 0;

x = improc2.utils.buildTypeCheckedValuesFromStruct(structOfThings);

assert(isa(x, 'improc2.interfaces.NamedValuesAndChoices'))

assert(length(x.itemNames) == 4)

assert(x.getValue('isGood') == true)
assert(strcmp(x.getValue('cellType'), 'crl'))
assert(strcmp(x.getValue('notes'), 'empty'))
assert(x.getValue('numNeighbors') == 0)

x.setValue('isGood', false)
x.setValue('cellType', 'hela')
x.setValue('notes', 'something')
x.setValue('numNeighbors', 4)

assert(x.getValue('isGood') == false)
assert(strcmp(x.getValue('cellType'), 'hela'))
assert(strcmp(x.getValue('notes'), 'something'))
assert(x.getValue('numNeighbors') == 4)

improc2.tests.shouldThrowError(@() x.setValue('isGood', 2))
improc2.tests.shouldThrowError(@() x.setValue('cellType', 'a549'))
improc2.tests.shouldThrowError(@() x.setValue('notes', false))
improc2.tests.shouldThrowError(@() x.setValue('numNeighbors', 'notAnumber'))
