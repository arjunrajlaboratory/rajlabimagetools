function img = addGaussianSpotToImage(img, gaussian2dSpots)
    
    if nargin < 3
        spotZPlanes = ones(size(gaussian2dSpots));
    end
    
    [imgXs, imgYs] = improc2.utils.getXandYPositionsAtEveryPixelInImage(img);
    
    for i = 1:length(gaussian2dSpots)
        zPlane = gaussian2dSpots(i).zPlane;
        img(:,:,zPlane) = img(:,:,zPlane) + gaussian2dSpots(i).valueAt(imgXs, imgYs);
    end
end

