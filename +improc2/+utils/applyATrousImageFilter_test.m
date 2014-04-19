improc2.tests.cleanupForTests;

filterParams = struct('numLevels', 2, 'sigma', 0.5);

img = zeros(20, 20);

img(4:16, 4:16) = img(4:16, 4:16) + 2;
img(12:13,12:13) = 4;
img(10:11, 6:7) = 4;

filterImg = improc2.utils.applyATrousImageFilter(img, filterParams);

figure(1); subplot(1,2,1);
imshow(scale(img), 'InitialMagnification', 'fit')
figure(1); subplot(1,2,2);
imshow(scale(filterImg), 'InitialMagnification', 'fit')