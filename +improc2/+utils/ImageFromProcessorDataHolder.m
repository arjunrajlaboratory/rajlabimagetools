classdef ImageFromProcessorDataHolder < handle
    
    properties (Access = private)
        processorDataHolder
    end
    
    methods
        function p = ImageFromProcessorDataHolder(processorDataHolder)
            p.processorDataHolder = processorDataHolder;
        end
        
        function varargout = getImage(p)
            [varargout{1:nargout}] = p.processorDataHolder.processorData.getImage();
        end
    end
end
