function croppedImg = cropImageToObjBoundingBox(img, objH)
    box = objH.getBoundingBox(); %[ul_corner_x x_width y_width]
    imgXInds = box(1):(box(1)+box(3));
    imgYInds = box(2):(box(2)+box(4));
    croppedImg = img(imgYInds,imgXInds,:);
end

