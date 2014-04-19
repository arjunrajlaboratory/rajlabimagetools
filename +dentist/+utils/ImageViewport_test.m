% construction test
dentist.tests.cleanupForTests;
imWidth = 3*(1024-103) + 1024;
imHeight = 2*(1024-103) + 1024;

viewport = dentist.utils.ImageViewport(imWidth, imHeight);

assert(viewport.imageWidth == imWidth)
assert(viewport.imageHeight == imHeight)

assert(viewport.ulCornerXPosition == 1)
assert(viewport.ulCornerYPosition == 1)

assert(viewport.width == viewport.imageWidth)
assert(viewport.height == viewport.imageHeight)

assert(viewport.centerXPosition == ...
    viewport.ulCornerXPosition + (viewport.width-1)/2);
assert(viewport.centerYPosition == ...
    viewport.ulCornerYPosition + (viewport.height-1)/2);

%% set roi width

dentist.tests.cleanupForTests;
imWidth = 3*(1024-103) + 1024;
imHeight = 2*(1024-103) + 1024;
viewport = dentist.utils.ImageViewport(imWidth, imHeight);

oldXCenter = viewport.centerXPosition;
oldYCenter = viewport.centerYPosition;
viewport = viewport.setWidth(1024);
viewport = viewport.setHeight(1024);
assert(viewport.width == 1024)
assert(viewport.height == 1024)
% center position is approximately maintained.
assert(abs(viewport.centerXPosition - oldXCenter) <= 0.5);
assert(abs(viewport.centerYPosition - oldYCenter) <= 0.5);
% UL coordinates are integers.
assert(mod(viewport.ulCornerXPosition, 1) == 0)
assert(mod(viewport.ulCornerYPosition, 1) == 0)

% Coercion at if requested size is too small or too big
viewport = viewport.setWidth(0.2);
viewport = viewport.setHeight(0.2);
assert(viewport.width == 1)
assert(viewport.height == 1)
assert(mod(viewport.ulCornerXPosition, 1) == 0)
assert(mod(viewport.ulCornerYPosition, 1) == 0)

viewport = viewport.setWidth(1.2 * imWidth);
viewport = viewport.setHeight(1.5 * imHeight);
assert(viewport.width == imWidth)
assert(viewport.height == imHeight)
assert(viewport.ulCornerXPosition == 1)
assert(viewport.ulCornerYPosition == 1)

% Coercion if requested size is not integer
viewport = viewport.setWidth(53.2);
viewport = viewport.setHeight(644.8);
assert(viewport.width == 53)
assert(viewport.height == 645)

%% scale  test
dentist.tests.cleanupForTests;
imWidth = 3*(1024-103) + 1024;
imHeight = 2*(1024-103) + 1024;
viewport = dentist.utils.ImageViewport(imWidth, imHeight);

oldwidth = viewport.width;
oldheight = viewport.height;
oldXCenter = viewport.centerXPosition;
oldYCenter = viewport.centerYPosition;
scaleFactor = 0.5;
viewport = viewport.scaleSize(scaleFactor);
assert(viewport.width == round(oldwidth * scaleFactor));
assert(viewport.height == round(oldheight * scaleFactor));
% center position is approximately maintained.
assert(abs(viewport.centerXPosition - oldXCenter) <= 0.5);
assert(abs(viewport.centerYPosition - oldYCenter) <= 0.5);

% Checks that ULCornerPosition is always an integer
for scaleFactor = (pi.^(1:10) - floor(pi.^(1:10))) %decimal parts of powers of pi
    viewport = dentist.utils.ImageViewport(imWidth, imHeight);
    viepowrt = viewport.scaleSize(scaleFactor);
    assert(mod(viewport.ulCornerXPosition, 1) == 0)
    assert(mod(viewport.ulCornerYPosition, 1) == 0)
end

% if you scale too big, coerces to width & height. 
viewport = dentist.utils.ImageViewport(imWidth, imHeight);
scaleFactor = 3;
viewport = viewport.scaleSize(scaleFactor);
assert(viewport.width == viewport.imageWidth)
assert(viewport.height == viewport.imageHeight)

%% move test
dentist.tests.cleanupForTests;
imWidth = 3*(1024-103) + 1024;
imHeight = 2*(1024-103) + 1024;
viewport = dentist.utils.ImageViewport(imWidth, imHeight);

viewport = viewport.setWidth(1024);
viewport = viewport.setHeight(1024);
oldXCenter = viewport.centerXPosition;
requestedX = oldXCenter - 207;
viewport = viewport.tryToCenterAtXPosition(requestedX);
assert(abs(viewport.centerXPosition - requestedX) <= 0.5);

oldYCenter = viewport.centerYPosition;
requestedY = oldXCenter - 207;
viewport = viewport.tryToCenterAtYPosition(requestedY);
assert(abs(viewport.centerYPosition - requestedY) <= 0.5);

% if request is too close to edge coerce so that roi stays in image:
requestedX = 100;
requestedY = 50;
viewport = viewport.tryToCenterAtXPosition(requestedX);
assert(viewport.ulCornerXPosition ==  1)

viewport = viewport.tryToCenterAtYPosition(requestedY);
assert(viewport.ulCornerYPosition ==  1)

viewport = viewport.tryToCenterAtXPosition(imWidth - 50);
assert(viewport.ulCornerXPosition == (imWidth - viewport.width + 1))

viewport = viewport.tryToCenterAtYPosition(imHeight - 100);
assert(viewport.ulCornerYPosition == (imHeight - viewport.height + 1))

%% Contains? method
dentist.tests.cleanupForTests;
imWidth = 3*(1024-103) + 1024;
imHeight = 2*(1024-103) + 1024;
viewport = dentist.utils.ImageViewport(imWidth, imHeight);

viewport = viewport.setWidth(1024);
viewport = viewport.setHeight(1024);
assert(~ viewport.contains(1,1))
assert(~ viewport.contains(1, viewport.centerYPosition))
assert(~ viewport.contains(viewport.centerXPosition, 1))
assert(viewport.contains(viewport.centerXPosition, ...
    viewport.centerYPosition ))

%% boundary rectangle drawing and image cropping

dentist.tests.cleanupForTests;
figure(1); ax1 = subplot(2,2,1);
img = rand(10,10);
imshow(img, 'InitialMagnification', 'fit')
viewport = dentist.utils.ImageViewport(10, 10);
viewport.drawBoundaryRectangle('EdgeColor','r','Parent',ax1);


viewport = viewport.setWidth(4);
viewport = viewport.setHeight(5);
viewport = viewport.tryToCenterAtXPosition(8);
viewport = viewport.tryToCenterAtYPosition(5);
viewport.drawBoundaryRectangle('EdgeColor','g','Parent',ax1);
imcrop1 = viewport.getCroppedImage(img);
ax2 = subplot(2,2,2);
imshow(imcrop1, 'InitialMagnification', 'fit', 'Parent', ax2);

viewport = viewport.setWidth(3);
viewport = viewport.setHeight(1);
viewport = viewport.tryToCenterAtXPosition(4);
viewport = viewport.tryToCenterAtYPosition(7);
viewport.drawBoundaryRectangle('EdgeColor','c', 'Parent', ax1);
imcrop2 = viewport.getCroppedImage(img);
ax3 = subplot(2,2,3);
imshow(imcrop2, 'InitialMagnification', 'fit', 'Parent', ax3);

viewport = viewport.setWidth(3);
viewport = viewport.setHeight(3);
viewport = viewport.tryToCenterAtXPosition(1);
viewport = viewport.tryToCenterAtYPosition(10);
viewport.drawBoundaryRectangle('EdgeColor','y', 'Parent', ax1);
imcrop3 = viewport.getCroppedImage(img);
ax4 = subplot(2,2,4);
imshow(imcrop3, 'InitialMagnification', 'fit', 'Parent', ax4);
