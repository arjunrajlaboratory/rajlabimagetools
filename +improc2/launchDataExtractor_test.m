improc2.tests.cleanupForTests;
inMemoryCollection = improc2.tests.data.collectionOfProcessedDAGObjects();

dataExtractor = improc2.launchDataExtractor(inMemoryCollection);
dataExtractor.extractFromProcessorData('cy.RNA', @getNumSpots, 'cy');
dataExtractor.extractFromProcessorData('cy.isClear', 'hasClearThreshold', 'cy:threshQC');

getObjArea = @(objH) sum(sum(getCroppedMask(objH)));
dataExtractor.extractFromObj('area', getObjArea);

cellTable = dataExtractor.extractAllToCellTable(); 
