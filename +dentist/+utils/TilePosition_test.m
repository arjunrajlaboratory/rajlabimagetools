dentist.tests.cleanupForTests;
%% Constructor
Nrows = 3; Ncols = 4;
x = dentist.utils.TilePosition(Nrows, Ncols);
assert(x.Nrows == Nrows)
assert(x.Ncols == Ncols)
assert(x.row == 1)
assert(x.col == 1)

x = dentist.utils.TilePosition(Nrows, Ncols, 3);
assert(x.Nrows == Nrows)
assert(x.Ncols == Ncols)
assert(x.tileNumber == 3)

x = dentist.utils.TilePosition(Nrows, Ncols, 2, 3);
assert(x.Nrows == Nrows)
assert(x.Ncols == Ncols)
assert(x.row == 2)
assert(x.col == 3)

%% go to number

x = dentist.utils.TilePosition(Nrows, Ncols);
x = x.goToNumber(5);
assert(x.tileNumber == 5)

%% go to edge

x = dentist.utils.TilePosition(Nrows, Ncols);
x = x.goToEdge('top');
x = x.goToEdge('left');
assert(x.row == 1);
assert(x.col == 1);

x = x.goToEdge('bottom');
assert(x.row == x.Nrows);
assert(x.col == 1);

x = x.goToEdge('right');
assert(x.row == x.Nrows);
assert(x.col == x.Ncols);

x = x.goToEdge('up');
assert(x.row == 1);
assert(x.col == x.Ncols);

x = x.goToEdge('down');
assert(x.row == x.Nrows);
assert(x.col == x.Ncols);

x = x.goToEdge('top');
assert(x.row == 1);
assert(x.col == x.Ncols);

x = x.goToEdge('left');
assert(x.row == 1);
assert(x.col == 1);

%% get Neighbor

x = dentist.utils.TilePosition(3, 4, 2, 2);

neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};
expectedRow = [1, 3, 2, 2, 1, 1, 3, 3];
expectedCol = [2, 2, 1, 3, 1, 3, 1, 3];

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    neighbor = x.getNeighbor(direction);
    assert(neighbor.row == expectedRow(i) && neighbor.col == expectedCol(i))
end

%% has Neighbor

x = dentist.utils.TilePosition(3, 3, 2, 2);

assert(x.hasNeighbor('up'))
assert(x.hasNeighbor({'up'}))

neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    assert(x.hasNeighbor(direction))
end

x = dentist.utils.TilePosition(3, 3, 3, 2);
neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};
expectedHasNeighbor = [true, false, true, true, ...
    true, true, false, false];

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    assert(x.hasNeighbor(direction) == expectedHasNeighbor(i))
end

x = dentist.utils.TilePosition(3, 3, 3, 1);
neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};
expectedHasNeighbor = [true, false, false, true, ...
    false, true, false, false];

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    assert(x.hasNeighbor(direction) == expectedHasNeighbor(i))
end

x = dentist.utils.TilePosition(3, 3, 2, 1);
neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};
expectedHasNeighbor = [true, true, false, true, ...
    false, true, false, true];

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    assert(x.hasNeighbor(direction) == expectedHasNeighbor(i))
end

x = dentist.utils.TilePosition(3, 3, 1, 1);
neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};
expectedHasNeighbor = [false, true, false, true, ...
    false, false, false, true];

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    assert(x.hasNeighbor(direction) == expectedHasNeighbor(i))
end

x = dentist.utils.TilePosition(3, 3, 1, 2);
neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};
expectedHasNeighbor = [false, true, true, true, ...
    false, false, true, true];

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    assert(x.hasNeighbor(direction) == expectedHasNeighbor(i))
end

x = dentist.utils.TilePosition(3, 3, 1, 3);
neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};
expectedHasNeighbor = [false, true, true, false, ...
    false, false, true, false];

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    assert(x.hasNeighbor(direction) == expectedHasNeighbor(i))
end

x = dentist.utils.TilePosition(3, 3, 2, 3);
neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};
expectedHasNeighbor = [true, true, true, false, ...
    true, false, true, false];

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    assert(x.hasNeighbor(direction) == expectedHasNeighbor(i))
end

x = dentist.utils.TilePosition(3, 3, 3, 3);
neighborDirections = {'up', 'down', 'left', 'right', ...
    'up-left', 'up-right', 'down-left', 'down-right'};
expectedHasNeighbor = [true, false, true, false, ...
    true, false, false, false];

for i = 1:length(neighborDirections)
    direction = neighborDirections{i};
    assert(x.hasNeighbor(direction) == expectedHasNeighbor(i))
end
