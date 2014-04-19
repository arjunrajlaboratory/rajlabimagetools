improc2.tests.cleanupForTests;

fakeObj = struct('annotations', struct());
objHolder = improc2.tests.MockObjHolder();
objHolder.obj = fakeObj;

x = improc2.ImageObjectAnnotationsHandle(objHolder);
assert(isempty(fields(objHolder.obj.annotations)))

% test of adding items directly

x.addItem('isGood', true)
x.addItem('cellType', 'crl')

assert(isequal({'isGood','cellType'}, x.itemNames(:)'))

assert(isfield(objHolder.obj.annotations, 'isGood'))
assert(objHolder.obj.annotations.isGood == true)
assert(isfield(objHolder.obj.annotations, 'cellType'))
assert(strcmp(objHolder.obj.annotations.cellType, 'crl'))

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

% test of getting items

assert(x.getItem('isGood') == true)
assert(strcmp(x.getItem('cellType'), 'crl'))

improc2.tests.shouldThrowError(@() x.getItem('notAnItem'), 'improc2:NoSuchItem')

% test of setting items

x.setItem('isGood', false)
assert(x.getItem('isGood') == false)
assert(objHolder.obj.annotations.isGood == false)

improc2.tests.shouldThrowError(...
    @() x.setItem('notAnItem', irrelevantNumber), 'improc2:NoSuchItem')

