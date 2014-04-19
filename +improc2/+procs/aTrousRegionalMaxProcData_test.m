improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();
channelName = 'cy';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);
imageProvider.loadImage(objH, channelName);
croppedImg = imageProvider.croppedimg;
objmask = objH.getCroppedMask();

x = improc2.procs.aTrousRegionalMaxProcData();


xProcessed = run(x, croppedImg, objmask);
assert(strcmp(xProcessed.hasClearThreshold, 'NA'))

disp(xProcessed.getNumSpots)    % shows number or spots
figure(1); clf; ax=axes();
[imH, spotsH] = xProcessed.plotImage(ax); % plots spot overlay
figure(2); clf; ax=axes();
[datH, threshH] = xProcessed.plotData(ax); % plots threshold curve & threshold

% Try again keeping an excessive number of aTrous levels. Results in poorer
% spot detection and thresholding.
x = improc2.procs.aTrousRegionalMaxProcData('filterParams',struct('numLevels',8));
xProcessed2 = run(x, croppedImg, objmask);
disp(xProcessed2.getNumSpots)    % shows number or spots
figure(3); clf; ax=axes();
[imH, spotsH] = xProcessed2.plotImage(ax); % plots spot overlay
figure(4); clf; ax=axes();
[datH, threshH] = xProcessed2.plotData(ax); % plots threshold curve & threshold

% % slice exclusion test

assert(xProcessed.getNumSpots() > 0, 'zslicing test only works if has spots')
assert(isempty(xProcessed.excludedSlices))

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