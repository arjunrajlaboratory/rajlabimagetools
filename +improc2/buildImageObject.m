function newObj = buildImageObject(maskImg, imagenumber, dirPath)
    
    channelInfo = findChannelsAndCorrespondingFiles(imagenumber, dirPath);
    
    baseGraph = improc2.dataNodes.buildMinimalImageObjectGraph(...
        maskImg, dirPath, channelInfo);
    
    newObj = improc2.dataNodes.GraphBasedImageObject();
    newObj.graph = baseGraph;
    
end

function channelInfo = findChannelsAndCorrespondingFiles(imagenumber, dirPath)

    [foundChannels, ~, imgExt] = getImageFiles(dirPath, imagenumber);
    channelNames = foundChannels;
    fileNames = cell(size(foundChannels));
    for k = 1:length(foundChannels)
        fname = sprintf('%s%s%s',foundChannels{k},imagenumber,imgExt{k});
        fileNames{k} = fname;
    end
    channelInfo = struct();
    channelInfo.channelNames = channelNames;
    channelInfo.fileNames = fileNames;
end
