improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();
channelName = 'cy';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);

channelStackContainer = improc2.dataNodes.ChannelStackContainer();
channelStackContainer.croppedImage = imageProvider.getImage(objH, channelName);
channelStackContainer.croppedMask = objH.getCroppedMask();

x = improc2.nodeProcs.RegionalMaxProcessedData();

xProcessed = run(x, channelStackContainer);

assert(isempty(x.regionalMaxIndices))
assert(isempty(x.regionalMaxValues))
assert(isempty(x.threshold))

assert(~ isempty(xProcessed.regionalMaxIndices))
assert(~ isempty(xProcessed.regionalMaxValues))
assert(~ isempty(xProcessed.threshold))

%% Slice exclusion

assert(isempty(xProcessed.excludedSlices))

% ensure there are spots
if getNumSpots(xProcessed) == 0
    xProcessed.threshold = xProcessed.threshold * 0.7;
end

assert(getNumSpots(xProcessed) > 0, 'Not possible to test slice exclusion if no spots')

[i, j, k] = xProcessed.getSpotCoordinates();
numSpots = xProcessed.getNumSpots();

% find slice with most spots:
zTabulation = tabulate(k);
[mostSpots, sliceWithMostSpots] = max(zTabulation(:,2));

assert(sum(k == sliceWithMostSpots) == mostSpots)

sliceToExclude = sliceWithMostSpots;

xProcessed.excludedSlices = sliceToExclude;

[iAfterExclusion, jAfterExclusion, kAfterExclusion] = ...
    xProcessed.getSpotCoordinates();
assert(sum(kAfterExclusion == sliceToExclude) == 0)

numSpotsAfterExclusion = xProcessed.getNumSpots();
assert(numSpotsAfterExclusion == numSpots - mostSpots)

regionalMaxIndices = xProcessed.regionalMaxIndices;
[allIs, allJs, allKs] = ind2sub(xProcessed.imageSize, regionalMaxIndices);

assert(sum(allKs == sliceToExclude) == 0)

assert(length(xProcessed.regionalMaxValues) == length(xProcessed.regionalMaxIndices))


[iwExcluded, jwExcluded, kwExcluded] = ...
    xProcessed.getSpotCoordinatesIncludingExcludedSlices();
assert(all(i == iwExcluded))
assert(all(j == jwExcluded))
assert(all(k == kwExcluded))

