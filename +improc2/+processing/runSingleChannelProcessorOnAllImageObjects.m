function runSingleChannelProcessorOnAllImageObjects(objH, iterator, croppedImgProvider, channelName, varargin)
    
    iterator.goToFirstObject();
    while iterator.continueIteration
        croppedImg  = croppedImgProvider.getImage(objH, channelName);
        croppedMask = objH.getCroppedMask();    
        fprintf('Running %s processor.\n', channelName)
        objH.runProcessor({croppedImg, croppedMask}, channelName, varargin{:});
        iterator.goToNextObject();
    end
end

