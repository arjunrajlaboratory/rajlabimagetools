improc2.tests.cleanupForTests;

backg = 0.5;
img = zeros(10,10) + backg;

g = improc2.fitting.Gaussian2dSpot(3.5, 7, 1, 1);
img = improc2.tests.addGaussianSpotToImage(img, g);

imshow(img, 'InitialMagnification', 'fit')

p = improc2.fitting.GaussianSpotFitter(img);

p.xGuess = 4;
p.yGuess = 8;

[gFitted, backgFitted] = p.fitSpot();

equalToWithin = @(a, b, tol) abs(a - b) <= tol;

assert(equalToWithin(g.xCenter, gFitted.xCenter, 0.001))
assert(equalToWithin(g.yCenter, gFitted.yCenter, 0.001))
assert(equalToWithin(g.sigma, gFitted.sigma, 0.001))
assert(equalToWithin(g.amplitude, gFitted.amplitude, 0.001))
assert(equalToWithin(backg, backgFitted, 0.001))

assert(gFitted.zPlane == 1)

% constraint setting

p.xMaxDeviationFromGuess = 0.1;

gConstrained = p.fitSpot();
assert(equalToWithin(g.yCenter, gConstrained.yCenter, 0.001))
assert(equalToWithin(gConstrained.xCenter, p.xGuess, p.xMaxDeviationFromGuess))

p.yMaxDeviationFromGuess = 0.1;

gConstrained = p.fitSpot();
assert(equalToWithin(gConstrained.yCenter, p.yGuess, p.yMaxDeviationFromGuess))
assert(equalToWithin(gConstrained.xCenter, p.xGuess, p.xMaxDeviationFromGuess))

% neighborhood size


img2 = zeros(20,20);

g1 = improc2.fitting.Gaussian2dSpot(13, 10, 1, 1);

gBroadBackg = improc2.fitting.Gaussian2dSpot(10, 10, 6, 2);

img2 = improc2.tests.addGaussianSpotToImage(img2, g1);
img2 = improc2.tests.addGaussianSpotToImage(img2, gBroadBackg);

imshow(scale(img2), 'InitialMagnification', 'fit')

p = improc2.fitting.GaussianSpotFitter(img2);

p.xGuess = 12;
p.yGuess = 10;
p.halfLengthOfRegionToFit = 2;

gSmallRegionFit = p.fitSpot();

p.halfLengthOfRegionToFit = 8;

gLargeRegionFit = p.fitSpot();

assert(gSmallRegionFit.sigma < 2)
assert(gLargeRegionFit.sigma > 5)



% changing which slice in which to look for spot

img = zeros(10,10,3);

zPlane = 1;
g = improc2.fitting.Gaussian2dSpot(5,5,1,1,zPlane);
img = improc2.tests.addGaussianSpotToImage(img, g);

zPlane = 2;
g = improc2.fitting.Gaussian2dSpot(5,5,1,2,zPlane);
img = improc2.tests.addGaussianSpotToImage(img, g);

zPlane = 3;
g = improc2.fitting.Gaussian2dSpot(5,5,1,4,zPlane);
img = improc2.tests.addGaussianSpotToImage(img, g);


p = improc2.fitting.GaussianSpotFitter(img);

p.xGuess = 5;
p.yGuess = 5;

p.spotZPlane = 1;
gFitted = p.fitSpot();
assert(equalToWithin(gFitted.amplitude, 1, 0.001))
assert(gFitted.zPlane == 1)

p.spotZPlane = 2;
gFitted = p.fitSpot();
assert(equalToWithin(gFitted.amplitude, 2, 0.001))
assert(gFitted.zPlane == 2)

p.spotZPlane = 3;
gFitted = p.fitSpot();
assert(equalToWithin(gFitted.amplitude, 4, 0.001))
assert(gFitted.zPlane == 3)