dentist.tests.cleanupForTests;

Nrows = 3; Ncols = 4;
x = dentist.utils.TileIterator(Nrows, Ncols);

assert(x.Nrows == Nrows)
assert(x.Ncols == Ncols)
assert(x.totalNumOfTiles == Nrows * Ncols)

tileRowsAndCols = [];

while x.hasNext();
    tile = x.next();
    tileRowsAndCols = [tileRowsAndCols; [tile.row tile.col]];
end

[p, q] = meshgrid(1:Nrows, 1:Ncols);
allPossibleRowsAndCols = [p(:) q(:)];

assert(size(allPossibleRowsAndCols, 1) == size(tileRowsAndCols, 1))

for i = 1:size(allPossibleRowsAndCols, 1)
    row = allPossibleRowsAndCols(i,1);
    col = allPossibleRowsAndCols(i,2);
    assert(any((tileRowsAndCols(:,1) == row) & (tileRowsAndCols(:,2)) == col))
end
