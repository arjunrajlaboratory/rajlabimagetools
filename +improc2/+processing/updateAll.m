function updateAll(dirPathOrAnArrayCollection, pathToImages)
    if nargin < 1
        dirPathOrAnArrayCollection = pwd;
    end
    if nargin < 2
        pathToImages = pwd;
    end
    
    tools = improc2.launchImageObjectTools(dirPathOrAnArrayCollection);
    
    assert(isa(tools.objectHandle, 'improc2.dataNodes.HandleToGraphBasedImageObject'),...
        'improc2:NoLegacySupport', 'this function only works on graph-based image objects')
    
    imageProviders = dentist.utils.makeFilledChannelArray(...
        tools.objectHandle.channelNames, ...
        @(channelName) improc2.ImageObjectCroppedStkProvider(pathToImages));
    
    tools.iterator.goToFirstObject();
    while tools.iterator.continueIteration
        fprintf('Working on %s\n', tools.iterator.getLocationDescription)
        tools.objectHandle.updateAllProcessedData(imageProviders)
        tools.iterator.goToNextObject();
    end
    fprintf('Done updating\n')
end