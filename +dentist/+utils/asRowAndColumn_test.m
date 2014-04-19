row = 1; col = 3;

[r, c] = dentist.utils.asRowAndColumn(row, col);
assert(r == row);
assert(c == col);

tile = dentist.utils.TilePosition(3, 4, 2, 4);
[r, c] = dentist.utils.asRowAndColumn(tile);
assert(r == 2)
assert(c == 4)
