improc2.tests.cleanupForTests;

numberOfColumns = 1;
minimumNumberOfRows = 1;
x = improc2.utils.FixedColumnsVariableRowsRectangleArrayPositionCalculator(...
    numberOfColumns, minimumNumberOfRows);

totalNumberOfRectangles = 2;

pos = x.getPositionOfRectangleInArray(1, totalNumberOfRectangles);
assert(all(pos == [0, 0.5, 1, 0.5]))

pos = x.getPositionOfRectangleInArray(2, totalNumberOfRectangles);
assert(all(pos == [0, 0, 1, 0.5]))

%
numberOfColumns = 2;
minimumNumberOfRows = 1;
x = improc2.utils.FixedColumnsVariableRowsRectangleArrayPositionCalculator(...
    numberOfColumns, minimumNumberOfRows);

totalNumberOfRectangles = 2;

pos = x.getPositionOfRectangleInArray(1, totalNumberOfRectangles);
assert(all(pos == [0, 0, 0.5, 1]))

pos = x.getPositionOfRectangleInArray(2, totalNumberOfRectangles);
assert(all(pos == [0.5, 0, 0.5, 1]))

%
numberOfColumns = 1;
minimumNumberOfRows = 4;
x = improc2.utils.FixedColumnsVariableRowsRectangleArrayPositionCalculator(...
    numberOfColumns, minimumNumberOfRows);

totalNumberOfRectangles = 2;

pos = x.getPositionOfRectangleInArray(1, totalNumberOfRectangles);
assert(all(pos == [0, 0.75, 1, 0.25]))

pos = x.getPositionOfRectangleInArray(2, totalNumberOfRectangles);
assert(all(pos == [0, 0.5, 1, 0.25]))

totalNumberOfRectangles = 10;

pos = x.getPositionOfRectangleInArray(1, totalNumberOfRectangles);
assert(all(pos == [0, 0.9, 1, 0.1]))

pos = x.getPositionOfRectangleInArray(2, totalNumberOfRectangles);
assert(all(pos == [0, 0.8, 1, 0.1]))

