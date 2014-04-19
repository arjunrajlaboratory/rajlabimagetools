improc2.tests.cleanupForTests;

mockImageObject = struct('annotations', struct());

objHolder = improc2.tests.MockObjHolder();
objHolder.obj = mockImageObject;

x = improc2.ImageObjectAnnotationsHolder(objHolder);

x.annotations = 'noTypeCheckingPerformedAtAll';
assert(isequal(objHolder.obj.annotations, 'noTypeCheckingPerformedAtAll'));

% but this is the intended use:
x.annotations = struct('isGood', improc2.TypeCheckedLogical(), ...
    'cellType', improc2.TypeCheckedFactor({'crl','melanoma'}));
assert(isa(objHolder.obj.annotations.isGood, 'improc2.TypeCheckedLogical') && ...
    isa(objHolder.obj.annotations.cellType, 'improc2.TypeCheckedFactor'))

