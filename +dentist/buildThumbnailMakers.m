function thumbnailMakers = buildThumbnailMakers(resources)
    
    centroidsAndNumSpotsSource = resources.centroidsAndNumSpotsSource;
    numSpotsToColorTranslators = resources.numSpotsToColorTranslators;
    imageWidthAndHeight = resources.imageWidthAndHeight;
    
    channelNames = numSpotsToColorTranslators.channelNames;
    
    thumbnailMakerResources = struct();
    thumbnailMakerResources.centroidsAndNumSpotsSource  = centroidsAndNumSpotsSource;
    thumbnailMakerResources.imageWidth                  = imageWidthAndHeight(1);
    thumbnailMakerResources.imageHeight                 = imageWidthAndHeight(2);
    
    thumbnailMakers = dentist.utils.ChannelArray(channelNames);
    
    for i = 1:length(channelNames)
        channelName = channelNames{i};
        thumbnailMakerResources.channelName = char(channelName);
        thumbnailMakerResources.numSpotsToColorTranslator = ...
            numSpotsToColorTranslators.getByChannelName(channelName);
        thumbnailMaker = dentist.utils.ThumbnailMaker(thumbnailMakerResources);
        thumbnailMakers = thumbnailMakers.setByChannelName(...
            thumbnailMaker, channelName);
    end   
end

