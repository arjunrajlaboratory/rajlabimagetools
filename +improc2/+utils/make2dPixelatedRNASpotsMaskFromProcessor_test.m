improc2.tests.cleanupForTests;


IandJ = [...
    2, 3;...
    4, 1];
Ks = [1,2]';
img = rand(4,4);

mockSpotsProcessor = improc2.tests.MockSpotCoordinatesAndImageProvider(...
    IandJ(:,1), IandJ(:,2), Ks, img);

pixelBlowUpSize = 1;
x = improc2.utils.make2dPixelatedRNASpotsMaskFromProcessor(...
    mockSpotsProcessor, pixelBlowUpSize);

expectedIm = false(size(img));
expectedIm(2,3) = true;
expectedIm(4,1) = true;
assert(isequal(x, expectedIm))
% expectedIm (logical)
% 0000
% 0010
% 0000
% 1000


%% pixel blowup:

pixelBlowUpSize = 3;
x = improc2.utils.make2dPixelatedRNASpotsMaskFromProcessor(...
    mockSpotsProcessor, pixelBlowUpSize);

expectedIm = false(size(img));
expectedIm(1:3, 2:4) = true;
expectedIm(3:4, 1:2) = true;
assert(isequal(x, expectedIm))

% expectedIm (logical)
% 0111
% 0111
% 1111
% 1100

%% points overlapping in z.

IandJ = [...
    2, 3;...
    2, 3];
Ks = [1,2]';
img = rand(4,4);

mockSpotsProcessor = improc2.tests.MockSpotCoordinatesAndImageProvider(...
    IandJ(:,1), IandJ(:,2), Ks, img);

pixelBlowUpSize = 1;
x = improc2.utils.make2dPixelatedRNASpotsMaskFromProcessor(...
    mockSpotsProcessor, pixelBlowUpSize);

expectedIm = false(size(img));
expectedIm(2,3) = true;
assert(isequal(x, expectedIm))

% expectedIm (logical)
% 0000
% 0010
% 0000
% 0000
