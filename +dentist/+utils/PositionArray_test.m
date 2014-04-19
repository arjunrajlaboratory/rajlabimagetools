Nrows = 3; Ncols = 4;

x = dentist.utils.PositionArray(Nrows, Ncols);

assert(x.Nrows == Nrows)
assert(x.Ncols == Ncols)

assert(isempty(x.getByPosition(1,1)))

tile = dentist.utils.TilePosition(Nrows, Ncols, 2, 3);
assert(isempty(x.getByPosition(tile)))

x = x.setByPosition('a', tile);
assert(strcmp('a', x.getByPosition(tile)))
assert(strcmp('a', x.getByPosition(tile.row, tile.col)))

x = x.setByPosition(53, tile.row, tile.col);
assert(53 == x.getByPosition(tile.row, tile.col));
assert(53 == x.getByPosition(tile));

%% aggregation test

x = dentist.utils.PositionArray(2, 2);
x = x.setByPosition(10, 1, 1);
x = x.setByPosition(11, 1, 2);
x = x.setByPosition(12, 2, 1);
x = x.setByPosition(13, 2, 2);
assert(x.aggregateAllPositions(@(a,b) a + b) == 46)
