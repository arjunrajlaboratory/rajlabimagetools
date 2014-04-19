improc2.tests.cleanupForTests;

vals = struct('isGood', true, 'cellType', 'hela');

x = improc2.utils.FieldsBasedItemCollectionHandle(vals);

assert(all(strcmp(x.itemNames(:)', {'isGood', 'cellType'})))

assert(x.getItem('isGood') == true)
assert(strcmp(x.getItem('cellType'), 'hela'))

x.setItem('isGood', false)
assert(x.getItem('isGood') == false)

improc2.tests.shouldThrowError(@() x.getItem('notAnItem'), ...
    'improc2:NoSuchItem')

improc2.tests.shouldThrowError(@() x.setItem('notAnItem', 3), ...
    'improc2:NoSuchItem')


x.addItem('isMitotic', improc2.TypeCheckedYesNoOrNA())
assert(ismember('isMitotic', x.itemNames))
assert(isa(x.getItem('isMitotic'), 'improc2.TypeCheckedYesNoOrNA'))

% test of rejecting invalid names.

improc2.tests.shouldThrowError(...
    @() x.addItem('cellType', 'hela'), ...
    'improc2:ItemWithNameExists')

irrelevantNumber = 0;
improc2.tests.shouldThrowError(...
    @() x.addItem('not a varname', irrelevantNumber),...
    'improc2:BadArguments')

% you can throw itemName error without attempting to add the item:

improc2.tests.shouldThrowError(...
    @() x.throwErrorIfInvalidNewItemName('cellType'), ...
    'improc2:ItemWithNameExists')

irrelevantNumber = 0;
improc2.tests.shouldThrowError(...
    @() x.throwErrorIfInvalidNewItemName('not a varname'),...
    'improc2:BadArguments')