classdef ImageObjectHandle < handle
    
    methods (Abstract = true)
        metadata = getMetaData(p)
        objMask = getCroppedMask(p)
        imFileMask = getMask(p)
        bbox = getBoundingBox(p)
        boolean = hasData(p, channelName, className)
        procData = getData(p, channelName, varargin)
        setData(p, procData, channelName, varargin)
        filename = getImageFileName(p, channelName)
        dirPath = getImageDirPath(p)
    end
end

