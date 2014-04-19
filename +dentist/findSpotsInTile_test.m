dentist.tests.cleanupForTests;

myDir = '~/code/dentist_test/3by3';
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(myDir);
imageDirectoryReader.implementGridLayout(3,3,'down','right','nosnake');

pixelOverlap = 103;

Nrows = 3;
Ncols = 3;


tile = dentist.utils.TilePosition(Nrows, Ncols, 1, 1);
myProvider = dentist.utils.ImageProvider(imageDirectoryReader, pixelOverlap, tile);

[spots, tables, thresholds] = dentist.findSpotsInTile( myProvider);
