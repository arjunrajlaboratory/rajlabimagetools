improc2.tests.cleanupForTests;

vals = struct('isGood', improc2.TypeCheckedLogical(true), ...
    'cellType', improc2.TypeCheckedFactor({'crl', 'hela'}));

collection = improc2.utils.FieldsBasedItemCollectionHandle(vals);

x = improc2.utils.NamedValuesAndChoicesFromItemCollection(collection);

assert(all(strcmp(x.itemClasses', {'improc2.TypeCheckedLogical', ...
    'improc2.TypeCheckedFactor'})))

assert(all(strcmp(x.itemNames', {'isGood', 'cellType'})))

assert(all(strcmp(...
    x.getChoices('cellType'), vals.cellType.choices)))

assert(x.getValue('isGood') == true)
assert(strcmp(x.getValue('cellType'), 'crl'))

x.setValue('isGood', false)
assert(x.getValue('isGood') == false)

x.setValue('cellType', 'hela')
assert(strcmp(x.getValue('cellType'), 'hela'))
