function viewport = setupImageViewport()
    viewport = dentist.utils.ImageViewport(10,10);
    viewport = viewport.setWidth(5);
    viewport = viewport.setHeight(3);
    viewport = viewport.tryToPlaceULCornerAtXPosition(2);
    viewport = viewport.tryToPlaceULCornerAtYPosition(3);
end