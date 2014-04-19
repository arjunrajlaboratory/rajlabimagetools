improc2.tests.cleanupForTests;

mask1 = false(30,30);
mask1(5:9, 5:9) = true;

mask2 = false(30,30);
mask2(20:24, 15:25) = true;

obj1 = struct('object_mask', struct('imfilemask', mask1));
obj2 = struct('object_mask', struct('imfilemask', mask2));

mask3 = false(30,30);
mask3(10:20, 10:20) = true;

objInAnotherArray = struct('object_mask', struct('imfilemask', mask3));

arrayCollection = improc2.utils.InMemoryObjectArrayCollection({[obj1, obj2], objInAnotherArray});
objHolder = improc2.utils.ObjectHolder();
navigator = improc2.utils.ImageObjectArrayCollectionNavigator(arrayCollection, objHolder);

objHandle = improc2.utils.HandleToLegacyimage_object(objHolder);

x = improc2.utils.MasksImageForAllObjectsInArray(objHandle, navigator);
assert(isequal(x.getImage(), mask1 | mask2))

navigator.tryToGoToArray(2);
assert(isequal(x.getImage(), mask3))
