improc2.tests.cleanupForTests;

mockExtender = improc2.tests.MockItemCollectionExtender();

x = improc2.utils.TypeCheckedItemCollectionExtender(mockExtender);

assert(isempty(fields(mockExtender.addedItems)))

% directly adding typechecked values

x.addItem('isGood', improc2.TypeCheckedLogical(true))
x.addItem('cellType', improc2.TypeCheckedFactor({'crl', 'hela'}))

assert(mockExtender.addedItems.isGood.value == true)
assert(strcmp(mockExtender.addedItems.cellType.value, 'crl'))

% coercion to type-checked values

x.addItem('isMitotic', false)
x.addItem('notes', '')
x.addItem('numNuclei', 2)
x.addItem('cellStage', {'G1', 'S', 'G2', 'M'})


assert(isa(mockExtender.addedItems.isMitotic, 'improc2.TypeCheckedLogical'))
assert(isa(mockExtender.addedItems.notes, 'improc2.TypeCheckedString'))
assert(isa(mockExtender.addedItems.numNuclei, 'improc2.TypeCheckedNumeric'))
assert(isa(mockExtender.addedItems.cellStage, 'improc2.TypeCheckedFactor'))

% error if not convertible. 

notConvertibleToTypeChecked = struct();
improc2.tests.shouldThrowError(...
    @() x.addItem('shouldFail', notConvertibleToTypeChecked),...
    'improc2:ConvertToTypeCheckedFailed')

% throw invalid itemName error wihtout trying to add item:

improc2.tests.shouldThrowError(...
    @() x.throwErrorIfInvalidNewItemName('cellStage'), ...
    'improc2:ItemWithNameExists')

irrelevantNumber = 0;
improc2.tests.shouldThrowError(...
    @() x.throwErrorIfInvalidNewItemName('not a varname'),...
    'improc2:BadArguments')


