improc2.tests.cleanupForTests;

img = zeros(10, 10, 3) + 0.3;

zPlane1 = 1;
g1 = improc2.fitting.Gaussian2dSpot(5.2, 4.8, 1.2, 1, zPlane1);
img = improc2.tests.addGaussianSpotToImage(img, g1);

zPlane2 = 2;
g2 = improc2.fitting.Gaussian2dSpot(7.5, 3.2, 0.8, 2, zPlane2);
img = improc2.tests.addGaussianSpotToImage(img, g2);

spotXGuesses = [5, 7];
spotYGuesses = [5, 3];
spotZPlanes = [zPlane1, zPlane2];

mockFilteredImage = 2*img;

[fittedSpots, fittedBackg] = improc2.fitting.fitSpotPositionsThenRefineForAmplitude(...
    mockFilteredImage, img, spotXGuesses, spotYGuesses, spotZPlanes);

equalToWithin = @(a, b, tol) abs(a - b) <= tol;

spotsAreNearlyEqual = @(spotA, spotB, tol) ...
    equalToWithin(spotA.xCenter, spotB.xCenter, tol) && ...
    equalToWithin(spotA.yCenter, spotB.yCenter, tol) && ...
    equalToWithin(spotA.sigma, spotB.sigma, tol) && ...
    equalToWithin(spotA.amplitude, spotB.amplitude, tol);

assert(spotsAreNearlyEqual(fittedSpots(1), g1, 0.01))
assert(spotsAreNearlyEqual(fittedSpots(2), g2, 0.01))

assert(fittedSpots(1).zPlane == zPlane1)
assert(fittedSpots(2).zPlane == zPlane2)