dentist.tests.cleanupForTests;

x = dentist.utils.PolygonStack();

poly1 = [10 10; 10 20; 20 15];
x.addPolygon(poly1);

poly2 = [30 20; 30 25; 35 25; 35 20]; 
x.addPolygon(poly2);

xandy = [1 1; 15 15; 60 40; 32.5 22.5];

mask = x.determineIfInAnyPolygon(xandy(:,1), xandy(:,2));
assert(all(mask == [false true false true]'));

x.removeLastPolygon();
mask = x.determineIfInAnyPolygon(xandy(:,1), xandy(:,2));
assert(all(mask == [false true false false]'));

x.removeLastPolygon();
mask = x.determineIfInAnyPolygon(xandy(:,1), xandy(:,2));
assert(all(mask == [false false false false]'));

x.addPolygon(poly1);
x.addPolygon(poly2);
mask = x.determineIfInAnyPolygon(xandy(:,1), xandy(:,2));
assert(all(mask == [false true false true]'));

polys = x.getPolygons();
assert(all(all(polys{1} == poly1)))
assert(all(all(polys{2} == poly2)))

x.removeAllPolygons();
mask = x.determineIfInAnyPolygon(xandy(:,1), xandy(:,2));
assert(all(mask == [false false false false]'));

