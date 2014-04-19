function [objH, dirPath, sliceWithSpots, imagenumber] = dataForTests()
%% Load an image object array here.
% Make sure that it has channels 'trans','dapi', and 'cy' (RNA),
% and that the associated image files are in this dirPath.

dirPath = improc2.tests.data.locator();
collection = improc2.tests.data.collectionOfProcessedObjects();
objArray = collection.getObjectsArray(1);
objectHolder = improc2.utils.ObjectHolder();
objectHolder.obj = objArray(1);
objH = improc2.ImageObjectHandle(objectHolder);
sliceWithSpots = 3;
imagenumber = '001';
