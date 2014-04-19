function [Xs, Ys] = getXandYPositionsAtEveryPixelInImage(img)
    imWidth = size(img, 2);
    imHeight = size(img, 1);
    theXs = 1:imWidth;
    Xs = repmat(theXs, imHeight, 1);
    theYs = (1:imHeight)';
    Ys = repmat(theYs, 1, imWidth);
end