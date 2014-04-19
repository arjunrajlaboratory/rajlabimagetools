function [ croppedimg, objmask ] = getCroppedImgAndMaskFromObj(objH, channelName)

tryImgObjInputs = isa(objH, 'improc2.interfaces.ImageObjectHandle');
tryImgObjInputs = tryImgObjInputs && ischar(channelName);

if ~tryImgObjInputs
    customstring = '\nRun with args (objH: ImageObjectHandle, channelName: string)';
    err = improc2.badArgumentsError(customstring);
    throw(err);
end 

objmask = objH.getCroppedMask();
croppedStkProvider = improc2.ImageObjectCroppedStkProvider();
croppedStkProvider.loadImage(objH, channelName);
croppedimg = croppedStkProvider.croppedimg;
delete(croppedStkProvider);
end

