classdef ImageObjectHandle < handle
    
    methods (Abstract = true)
        metadata = getMetaData(p)
        objMask = getCroppedMask(p)
        imFileMask = getMask(p)
        bbox = getBoundingBox(p)
        boolean = hasProcessorData(p, channelName, className)
        procData = getProcessorData(p, channelName, varargin)
        setProcessorData(p, procData, channelName, varargin)
        filename = getImageFileName(p, channelName)
        dirPath = getImageDirPath(p)
    end
end

