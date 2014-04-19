improc2.tests.cleanupForTests;

getMaxIntensityFUNC = @() 3.0;
contraster = improc2.utils.MaxSettingContraster(getMaxIntensityFUNC);

img = eye(2,2); 
minAndMaxInUnscaledImage = [1.0 2.0];
imgHolder = improc2.tests.MockScaledImageHolder(img, minAndMaxInUnscaledImage);

x = improc2.utils.ContrastedScaledImageHolder(imgHolder, contraster);

expectedImAfterContrasting = img/2;

assert(isequal(x.getImage(), expectedImAfterContrasting))
