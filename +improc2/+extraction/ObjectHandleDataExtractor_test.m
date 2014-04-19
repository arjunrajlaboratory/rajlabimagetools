improc2.tests.cleanupForTests;

inMemoryCollection = improc2.tests.data.collectionOfProcessedObjects();

browsingTools = improc2.launchImageObjectBrowsingTools(inMemoryCollection);

objectHandle = browsingTools.objectHandle;

x = improc2.extraction.ObjectHandleDataExtractor(objectHandle);

getArea = @(objH) sum(sum(objH.getCroppedMask()));
getThirdElement = @(x) x(3);
x.setExtractingFunction('area', getArea)
x.setExtractingFunction('bboxWidth', @(objH) getThirdElement(objH.getBoundingBox()))

if any(size(objectHandle.getCroppedMask) > 1)
    improc2.tests.shouldThrowError(@() x.setExtractingFunction('mask', @getCroppedMask))
end


expectedArea = getArea(objectHandle);
expectedBBoxWidth = getThirdElement(objectHandle.getBoundingBox());

extracted = x.extractData();

assert(iscell(extracted))

assert(isequal(extracted{1,1}, 'area'))
assert(isequal(extracted{1,2}, expectedArea))
assert(isequal(extracted{2,1}, 'bboxWidth'))
assert(isequal(extracted{2,2}, expectedBBoxWidth))