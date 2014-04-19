improc2.tests.cleanupForTests;

vals = struct('isGood', improc2.TypeCheckedLogical(true), ...
    'cellType', improc2.TypeCheckedFactor({'crl', 'hela'}), ...
    'numNeighbors', improc2.TypeCheckedNumeric(2), ...
    'isMitotic', improc2.TypeCheckedYesNoOrNA());
collection = improc2.utils.FieldsBasedItemCollectionHandle(vals);
namedValues = improc2.utils.NamedValuesAndChoicesFromItemCollection(collection);

x = improc2.extraction.AnnotationDataExtractor(namedValues);

extractedData = x.extractData();

extractedNames = extractedData(:,1);
extractedValues = extractedData(:,2);

[sortedExtractedNames, ordering] = sort(extractedNames);
sortedExtractedValues = extractedValues(ordering);


expectedNames = {'isGood', 'cellType', 'numNeighbors', 'isMitotic'}';
expectedValues = {'true', 'crl', '2', 'NA'}';

[sortedNames, ordering] = sort(expectedNames);
sortedValues = expectedValues(ordering);

assert(isequal(sortedExtractedNames, sortedNames))
assert(isequal(sortedExtractedValues, sortedValues))
