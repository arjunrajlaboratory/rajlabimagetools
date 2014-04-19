improc2.tests.cleanupForTests;

mockPolygonGrouper = improc2.tests.MockPolygonBasedGrouper();

x = improc2.utils.PolygonAddableFromPolygonGrouper(mockPolygonGrouper);

poly = [1,1;2,2];

x.addPolygon(poly);

assert(isequal(mockPolygonGrouper.mostRecentPolygon, poly))