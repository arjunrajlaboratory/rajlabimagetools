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

x = improc2.utils.ImageObjectsCentroidsSource(navigator, objHandle);

centroids = x.getCentroids();
assert(length(centroids) == 2)

[x1, y1] = improc2.utils.getCenterOfConnectedBWImage(mask1);
[x2, y2] = improc2.utils.getCenterOfConnectedBWImage(mask2);

assert(x1 == centroids.xPositions(1))
assert(x2 == centroids.xPositions(2))
assert(y1 == centroids.yPositions(1))
assert(y2 == centroids.yPositions(2))


figure(1); imshow(mask1|mask2, 'InitialMagnification', 'fit')
hold on;
plot(centroids.xPositions, centroids.yPositions, '.r')
hold off;


navigator.tryToGoToArray(2);

centroids = x.getCentroids();
assert(length(centroids) == 1)

[x3, y3] = improc2.utils.getCenterOfConnectedBWImage(mask3);

assert(x3 == centroids.xPositions(1))
assert(x3 == centroids.xPositions(1))