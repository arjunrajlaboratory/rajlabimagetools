function [centroids] = findCentroidsInImage(imageSource, verboseFlag)
    if nargin < 2
        verboseFlag = false;
    end
    
    if isnumeric(imageSource)
        dapiImage = imageSource;
    else 
        dapiImage = imageSource.getExtendedDapiImage;
    end
    
    dapiImg = im2double(dapiImage);
    
    i = 75;    

    filt = fspecial('log',[i i],35);

    im2 = imfilter(dapiImg,filt,'replicate');

    irm = imregionalmax(-im2);


    im3 = -im2.*irm;
    im4 = im3 > 3e-7; % this is the parameter to tweak!!!!!!

    BWObjects = bwconncomp(im4);
    stats = regionprops(BWObjects,'Centroid','BoundingBox');

    centroids = [stats(:).Centroid];  
    centroids = reshape(centroids,2,[]);

    xPositions = centroids(1,:);
    yPositions = centroids(2,:);
  
    centroids = dentist.utils.Centroids(xPositions,yPositions);
    
    if verboseFlag
        figure(1);
        imshow(imadjust(dapiImage),'InitialMagnification','fit')
        plotCirclesAtCoordinates(centroids.xPositions,centroids.yPositions);
    end
    
end

function plotCirclesAtCoordinates(x, y)
    hold on;
    plot(x,y,'or');
    hold off;
end
