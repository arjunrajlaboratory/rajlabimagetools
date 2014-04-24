improc2.tests.cleanupForTests;

pData = improc2.procs.ManuallySelectedPointsData();

point1X = 3;
point1Y = 2;
point1Z = 6;

pData = addPoint(pData, point1X, point1Y, point1Z);

assert(all(getPoints(pData)==[point1X,point1Y,point1Z]));

point2X = 5;
point2Y = 7;
point2Z = 0;

pData = addPoint(pData, point2X, point2Y, point2Z);

expectedPoints = [point1X, point1Y, point1Z; point2X, point2Y, point2Z];
assert(isequal(getPoints(pData),expectedPoints))

pData = removeLastPoint(pData);
assert(all(getPoints(pData)==[point1X,point1Y,point1Z]));

pData = removeLastPoint(pData);
assert(isempty(getPoints(pData)));

pData = removeLastPoint(pData);
assert(isempty(getPoints(pData)));
