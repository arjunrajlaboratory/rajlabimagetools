classdef ImageHolderFromImageObjectHandle < handle
    
    properties (Access = private)
        imObHandle
        channelName
        extraArgsForChoosingProcessor
    end
    
    methods
        function p = ImageHolderFromImageObjectHandle(imObHandle, ...
                channelName, varargin)
            p.imObHandle = imObHandle;
            p.channelName = channelName;
            p.extraArgsForChoosingProcessor = varargin;
        end
        function varargout = getImage(p)
            proc = p.imObHandle.getData(p.channelName, ...
                p.extraArgsForChoosingProcessor{:});
            [varargout{1:nargout}] = proc.getImage();
        end
    end
end

