dentist.tests.cleanupForTests;


poly1 = [10 10; 10 20; 20 15];
poly2 = [30 20; 30 25; 35 25; 35 20]; 

xandy = [1 1; 15 15; 60 40; 32.5 22.5];

deletionHandler = dentist.tests.MockDeletionSettableByXYFilter(...
    xandy(:,1), xandy(:,2));

polygonStack = dentist.utils.PolygonStack();
x = dentist.utils.PolygonsBasedDeletionsTool(polygonStack, deletionHandler);

assert(all(deletionHandler.deleted == [false false false false]'));
assert(isempty(x.getPolygons))

x.addPolygon(poly1)
assert(all(deletionHandler.deleted == [false true false false]'));

x.addPolygon(poly2)
assert(all(deletionHandler.deleted == [false true false true]'));

x.removeAllPolygons();
assert(all(deletionHandler.deleted == [false false false false]'));

x.addPolygon(poly2)
assert(all(deletionHandler.deleted == [false false false true]'));

x.addPolygon(poly1)
assert(all(deletionHandler.deleted == [false true false true]'));

polys = x.getPolygons();
assert(length(polys) == 2)

x.removeLastPolygon();
assert(all(deletionHandler.deleted == [false false false true]'));
