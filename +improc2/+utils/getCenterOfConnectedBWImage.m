function [x, y] = getCenterOfConnectedBWImage(bwimg)

    rp = regionprops(bwimg);
    x = rp.Centroid(1);
    y = rp.Centroid(2);
    
end

