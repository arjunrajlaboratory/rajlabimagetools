function viewport = makeImageViewportScaledToImageSize(originalViewport, ...
        imageWidth, imageHeight)
    viewport = dentist.utils.ImageViewport(imageWidth, imageHeight);
    viewport = viewport.setToMatchViewport(originalViewport);
end
