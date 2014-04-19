
% You first need to load a spotsAndCentroids and an imageProvider into the
% workspace.

imageWidthAndHeight = dentist.utils.computeTiledImageWidthAndHeight(imageProvider);
t = dentist.utils.makeRNADensityIntensityThumbnail(spotsAndCentroids, ...
    imageWidthAndHeight, 'tmr');