improc2.tests.cleanupForTests

fakeimage_object = struct('isGood', true, 'metadata', struct());
objHolder = improc2.tests.MockObjHolder();
objHolder.obj = fakeimage_object;

x = improc2.Legacyimage_objectAnnotationsHandle(objHolder);
assert(isempty(fields(objHolder.obj.metadata)))

% isGood is available as a typecheckedlogical and is automatically
% converted back to a pure logical on save.

isgood = x.getItem('isGood');
assert(isa(isgood, 'improc2.TypeCheckedLogical'))
assert(isgood.value == true)
isgood.value = false;
x.setItem('isGood', isgood)
assert(objHolder.obj.isGood == false)

assert(strcmp(x.itemNames, {'isGood'}))

% test of adding items directly

x.addItem('cellType', 'notTypeChecked')

assert(isequal({'isGood','cellType'}, x.itemNames(:)'))

assert(isfield(objHolder.obj.metadata.annotations, 'cellType'))
assert(strcmp(objHolder.obj.metadata.annotations.cellType, 'notTypeChecked'))

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

assert(strcmp(x.getItem('cellType'), 'notTypeChecked'))
improc2.tests.shouldThrowError(@() x.getItem('notAnItem'), ...
    'improc2:NoSuchItem')

% test of setting items

x.setItem('cellType', 'anythingElse')
assert(strcmp(x.getItem('cellType'), 'anythingElse'))
assert(strcmp(objHolder.obj.metadata.annotations.cellType, 'anythingElse'))

improc2.tests.shouldThrowError(...
    @() x.setItem('notAnItem', irrelevantNumber), 'improc2:NoSuchItem')
