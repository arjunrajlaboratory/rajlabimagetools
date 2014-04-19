improc2.tests.cleanupForTests;

inMemoryCollection = improc2.tests.data.collectionOfProcessedObjects();

browsingTools = improc2.launchImageObjectBrowsingTools(inMemoryCollection);

objectHandle = browsingTools.objectHandle;

x = improc2.extraction.ProcessorDataExtractor(objectHandle);

x.setExtractField('tmr.isClear', 'hasClearThreshold', 'tmr')
x.setExtractFuncOrMethod('cy.RNA', @getNumSpots, 'cy')

if ~isfield(objectHandle.getProcessorData('trans'), 'hasClearThreshold')
    improc2.tests.shouldThrowError(@() x.setExtractField('trans.isClear', ...
        'hasClearThreshold', 'trans'))
end

if length(getSpotCoordinates(objectHandle.getProcessorData('cy'))) > 0
    improc2.tests.shouldThrowError(@() x.setExtractFuncOrMethod('cy.RNA', ...
        @getSpotCoordinates, 'cy'))
end


expectedTMRisClear = getfield(objectHandle.getProcessorData('tmr'), 'hasClearThreshold');
expectedCySpots = getNumSpots(objectHandle.getProcessorData('cy'));

extracted = x.extractData();

assert(iscell(extracted))

assert(isequal(extracted{1,1}, 'tmr.isClear'))
assert(isequal(extracted{1,2}, expectedTMRisClear))
assert(isequal(extracted{2,1}, 'cy.RNA'))
assert(isequal(extracted{2,2}, expectedCySpots))