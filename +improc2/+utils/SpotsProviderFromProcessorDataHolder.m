classdef SpotsProviderFromProcessorDataHolder < handle
    
    properties (Access = private)
        processorDataHolder
    end
    
    methods
        function p = SpotsProviderFromProcessorDataHolder(processorDataHolder)
            p.processorDataHolder = processorDataHolder;
        end
        
        function [I, J, K] = getSpotCoordinates(p)
            [I, J, K] = p.processorDataHolder.processorData.getSpotCoordinates();
        end
        
        function num = getNumSpots(p)
            num = p.processorDataHolder.processorData.getNumSpots();
        end
    end
    
end

