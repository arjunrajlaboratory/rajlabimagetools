improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests();
channelName = 'cy';

imageProvider = improc2.ImageObjectCroppedStkProvider(dirPath);
imageProvider.loadImage(objH, channelName);
croppedImg = imageProvider.croppedimg;
objmask = objH.getCroppedMask();

x = improc2.procs.RegionalMaxProcData();

xProcessed = run(x, croppedImg, objmask);

assert(strcmp(xProcessed.hasClearThreshold, 'NA'))

disp(xProcessed.getNumSpots)    % shows number or spots
figure(1); clf; ax=axes();
[imH, spotsH] = xProcessed.plotImage(ax); % plots spot overlay
set(spotsH, 'color', 'red') % Changes spots to red.
figure(2); clf; ax=axes();
[datH, threshH] = xProcessed.plotData(ax); % plots threshold curve & threshold
set(datH, 'color', 'red') % changes curve to red.

% Slice exclusion

assert(isempty(xProcessed.excludedSlices))

if xProcessed.getNumSpots() > 0
    
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
    
else
    fprintf('Skipping slice exclusion testing since there are no spots.\n')
end
