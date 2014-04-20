dentist.tests.cleanupForTests;

testDataDir = dentist.tests.data.locator();
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(testDataDir);
imageDirectoryReader.implementGridLayout(2, 2,'down','right','nosnake');

pixelOverlap = 103;

Nrows = 2;
Ncols = 2;


tile = dentist.utils.TilePosition(Nrows, Ncols, 1, 1);
myProvider = dentist.utils.ImageProvider(imageDirectoryReader, pixelOverlap, tile);

centroids = dentist.findCentroidsInImage(myProvider);
