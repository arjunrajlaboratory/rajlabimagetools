improc2.tests.cleanupForTests;

fourByFourIm = zeros(4,4);

imHolder = improc2.tests.MockImageHolder(fourByFourIm);

x = improc2.utils.ImageSizeAdaptiveViewportHolder(imHolder);

full4x4Viewport = x.getViewport();

assert(full4x4Viewport.imageWidth == 4 && full4x4Viewport.imageHeight == 4)
assert(full4x4Viewport.width == 4 && full4x4Viewport.height == 4)

% full4x4Viewport ~
% 1111
% 1111
% 1111
% 1111

smallViewport = full4x4Viewport.setWidth(3);
smallViewport = smallViewport.setHeight(3);
smallViewport = smallViewport.tryToPlaceULCornerAtXPosition(2);
smallViewport = smallViewport.tryToPlaceULCornerAtYPosition(2);

% smallViewport ~
% 0000
% 0111
% 0111
% 0111

x.setViewport(smallViewport)
assert(isequal(x.getViewport(), smallViewport))


eightByEightIm = zeros(8,8);
imHolder.setImage(eightByEightIm);

adaptedSmallViewport = x.getViewport();

assert(adaptedSmallViewport.imageWidth == 8 && adaptedSmallViewport.imageHeight == 8)
assert(adaptedSmallViewport.width == 3 && adaptedSmallViewport.height == 3)

assert(adaptedSmallViewport.centerXPosition == ...
    smallViewport.centerXPosition * 8/4)
assert(adaptedSmallViewport.centerYPosition == ...
    smallViewport.centerYPosition * 8/4)

% adaptedSmallViewport ~
% 00000000
% 00000000
% 00000000
% 00000000
% 00001110
% 00001110
% 00001110
% 00000000

% make the viewport bigger than the 4x4 image and set it:

bigViewport = adaptedSmallViewport.setWidth(5);
bigViewport = bigViewport.setHeight(5);

% bigViewport ~
% 00000000
% 00000000
% 00000000
% 00011111
% 00011111
% 00011111
% 00011111
% 00011111

x.setViewport(bigViewport);
assert(isequal(x.getViewport, bigViewport))

imHolder.setImage(fourByFourIm);

adaptedBigViewport = x.getViewport();
assert(isequal(adaptedBigViewport, full4x4Viewport))

% adaptedBigViewport ~
% 1111
% 1111
% 1111
% 1111

% without setting viewport, switching back keeps the old viewport memory

imHolder.setImage(eightByEightIm);
assert(isequal(x.getViewport(), bigViewport));

% but setting to a fully zoomed out viewport ...

imHolder.setImage(fourByFourIm);
assert(isequal(adaptedBigViewport, full4x4Viewport))
x.setViewport(full4x4Viewport)

imHolder.setImage(eightByEightIm);
assert(~isequal(x.getViewport(), bigViewport));

adaptedFullViewport = x.getViewport();
assert(adaptedFullViewport.imageWidth == 8 && adaptedFullViewport.imageHeight == 8)
assert(adaptedFullViewport.width == 8 && adaptedFullViewport.height == 8)
