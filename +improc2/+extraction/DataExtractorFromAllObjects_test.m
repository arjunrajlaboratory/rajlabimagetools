improc2.tests.cleanupForTests;

inMemoryCollection = improc2.tests.data.collectionOfProcessedDAGObjects();

tools = improc2.launchImageObjectTools(inMemoryCollection);

objectHandle = tools.objectHandle;

annotationExtractor = improc2.extraction.AnnotationDataExtractor(tools.annotations);
processorDataExtractor = improc2.extraction.ProcessorDataExtractor(objectHandle);
processorDataExtractor.setExtractField('', 'hasClearThreshold', 'cy:threshQC')
processorDataExtractor.setExtractFuncOrMethod('tmr.RNA', @getNumSpots, 'tmr')
objectHandleExtractor = improc2.extraction.ObjectHandleDataExtractor(objectHandle);
objectHandleExtractor.setExtractingFunction('area', @(objH) sum(sum(getCroppedMask(objH))))

x = improc2.extraction.DataExtractorFromAllObjects(...
    tools.iterator, tools.navigator, objectHandleExtractor, processorDataExtractor, ...
    annotationExtractor);
x.extractFromProcessorData('', 'hasClearThreshold', 'tmr:threshQC') 
x.extractFromProcessorData('', @getNumSpots, 'cy')

fileToWrite = [tempname, '.csv'];
x.extractAllToCSVFile(fileToWrite)

