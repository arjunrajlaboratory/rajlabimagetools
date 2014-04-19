improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests(); cd(dirPath) % loads an image object and a dirPath
x = improc2.ImageObject(objH.getMask(), imagenumber, dirPath);

assert(isa(x.processors, 'improc2.MultiChannelProcManager'))

assert(strcmp(x.dirPath, dirPath))
assert(all(all(x.object_mask.imfilemask == objH.getMask())))
assert(all(all(x.object_mask.mask == objH.getCroppedMask())))
assert(all(all(x.object_mask.boundingbox == objH.getBoundingBox())))
assert(isstruct(x.metadata))

assert(x.annotations.isGood.value == true)
assert(isa(x.annotations.isGood, 'improc2.TypeCheckedLogical'))
