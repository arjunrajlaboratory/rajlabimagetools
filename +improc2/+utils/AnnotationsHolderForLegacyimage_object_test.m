improc2.tests.cleanupForTests

fakeimage_object = struct('isGood', true, 'metadata', struct());
objHolder = improc2.tests.MockObjHolder();
objHolder.obj = fakeimage_object;

x = improc2.utils.AnnotationsHolderForLegacyimage_object(objHolder);

annots = x.annotations;
assert(isequal(fields(annots), {'isGood'}))
assert(isa(annots.isGood, 'improc2.TypeCheckedLogical'))
assert(isequal(annots.isGood.value, true))

annots.cellType = 'anythingWhatsoever';

assert(~ isfield(objHolder.obj.metadata, 'annotations'))
x.annotations = annots;
assert(isfield(objHolder.obj.metadata, 'annotations'))
assert(isfield(objHolder.obj.metadata.annotations, 'cellType'))
assert(isequal(objHolder.obj.metadata.annotations.cellType, 'anythingWhatsoever'))
assert(isequal(objHolder.obj.metadata.annotations.cellType, x.annotations.cellType))

assert(~ isfield(objHolder.obj.metadata.annotations, 'isMitotic'))
x.annotations.isMitotic = 'thisValueIsNotChecked';
assert(isfield(objHolder.obj.metadata.annotations, 'isMitotic'))

x.annotations.isGood.value = false;
assert(objHolder.obj.isGood == false)
x.annotations.isGood.value = true;
assert(objHolder.obj.isGood == true)

% isGood requires special treatment
annots = x.annotations;
assert(isa(annots.isGood, 'improc2.TypeCheckedLogical'))
bareLogical = false;
annots.isGood = bareLogical;
try
    x.annotations = annots;
    error('expected an error')
catch err
    if ~strcmp(err.message, 'expected an error')
        fprintf('Triggered error as expected:\n')
        disp(err.message)
    end
end
