improc2.tests.cleanupForTests;

inMemoryCollection = improc2.tests.data.collectionOfProcessedDAGObjects();

browsingTools = improc2.launchImageObjectBrowsingTools(inMemoryCollection);

objectHandle = browsingTools.objectHandle;

x = improc2.extraction.ProcessorDataExtractor(objectHandle);

x.setExtractField('tmr.isClear', 'hasClearThreshold', 'tmr:threshQC')
x.setExtractFuncOrMethod('cy.RNA', @getNumSpots, 'cy')

if ~isfield(objectHandle.getData('trans'), 'hasClearThreshold')
    improc2.tests.shouldThrowError(@() x.setExtractField('trans.isClear', ...
        'hasClearThreshold', 'trans'))
end

if length(getSpotCoordinates(objectHandle.getData('cy'))) > 0
    improc2.tests.shouldThrowError(@() x.setExtractFuncOrMethod('cy.RNA', ...
        @getSpotCoordinates, 'cy'))
end


expectedTMRisClear = getfield(objectHandle.getData('tmr:threshQC'), 'hasClearThreshold');
expectedCySpots = getNumSpots(objectHandle.getData('cy'));

extracted = x.extractData();

assert(iscell(extracted))

assert(isequal(extracted{1,1}, 'tmr.isClear'))
assert(isequal(extracted{1,2}, expectedTMRisClear))
assert(isequal(extracted{2,1}, 'cy.RNA'))
assert(isequal(extracted{2,2}, expectedCySpots))
