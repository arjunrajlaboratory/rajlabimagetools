improc2.tests.cleanupForTests;

bbox = [4 5 3 4];
fakeObjH = struct();
fakeObjH.getBoundingBox = @() bbox;

im = rand(10,10);
figure(1); subplot(1,2,1);
imshow(im, 'InitialMagnification', 'fit')

rectangle('Position', bbox, 'EdgeColor', 'red')

croppedIm = improc2.utils.cropImageToObjBoundingBox(im, fakeObjH);
subplot(1,2,2)
imshow(croppedIm, 'InitialMagnification', 'fit')

expectedCrop = im(bbox(2):(bbox(2)+bbox(4)), bbox(1):(bbox(1)+bbox(3)));
assert(isequal(expectedCrop, croppedIm))
