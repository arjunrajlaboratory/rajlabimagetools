improc2.tests.cleanupForTests;

vals = struct('isGood', improc2.TypeCheckedLogical(true), ...
    'cellType', improc2.TypeCheckedFactor({'crl', 'hela'}));

collection = improc2.utils.FieldsBasedItemCollectionHandle(vals);

namedValues = improc2.utils.NamedValuesAndChoicesFromItemCollection(collection);

fprintf('* should print something informative about isGood and cellType:\n')
improc2.utils.displayDescriptionOfNamedValuesAndChoices(namedValues);