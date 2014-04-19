improc2.tests.cleanupForTests;

channelHolder = dentist.utils.ChannelSwitchCoordinator({'cy', 'tmr'});
channelHolder.setChannelName('tmr');

img = eye(2,2); 
minAndMaxInUnscaledImage = [1.0 2.0];
saturationValueOfImage = minAndMaxInUnscaledImage(2); 

imageHolder = improc2.tests.MockScaledImageHolder(img, minAndMaxInUnscaledImage);

x = improc2.utils.FixedContrastSettings(channelHolder, imageHolder);

x.setSaturationValue(30)
assert(x.getSaturationValue() == 30)

x.setSaturationValue(50, 'tmr')
assert(x.getSaturationValue() == 50)

% if you get the saturation value when it has not been set, it will be set
% to the current image.

channelHolder.setChannelName('cy')
assert(x.getSaturationValue() == saturationValueOfImage)

channelHolder.setChannelName('tmr')
assert(x.getSaturationValue() == 50)
x.setSaturationValueToCurrentImage();
assert(x.getSaturationValue() == saturationValueOfImage)
