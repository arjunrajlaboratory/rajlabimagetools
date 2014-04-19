improc2.tests.cleanupForTests;

img = zeros(10,10);
imgXs = repmat(1:10, [10, 1]);
imgYs = repmat((1:10)', [1, 10]);

gaussSpot = improc2.fitting.Gaussian2dSpot(3, 5, 1, 1);
img = img + gaussSpot.valueAt(imgXs, imgYs);

imshow(img, 'InitialMagnification', 'fit')