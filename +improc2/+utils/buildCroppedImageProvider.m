function croppedImgProvider = buildCroppedImageProvider(dirPathOrAnArrayCollection)
    if isa(dirPathOrAnArrayCollection, 'improc2.interfaces.ObjectArrayCollection')
        croppedImgProvider = improc2.ImageObjectCroppedStkProvider();
    else
        dirPath = dirPathOrAnArrayCollection;
        croppedImgProvider = improc2.ImageObjectCroppedStkProvider(dirPath);
    end
end