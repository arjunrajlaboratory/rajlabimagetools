improc2.tests.cleanupForTests;

getMaxIntensityFUNC = @() 3.0;


x = improc2.utils.MaxSettingContraster(getMaxIntensityFUNC);

img = eye(2,2); 
minAndMaxInUnscaledImage = [1.0 2.0];

scaledIm = x.contrast(img, minAndMaxInUnscaledImage);

assert(isequal( scaledIm, img/2))
