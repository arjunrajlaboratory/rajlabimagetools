classdef blobPerimProviderFromProcessorDataHolder < handle
    
    properties 
        processorData
    end
    
    methods
        function p = blobPerimProviderFromProcessorDataHolder(processorDataHolder)
            p.processorData = processorDataHolder;
        end
%         
        function [blobMasks, perimeters] = getPerimeters(p)
            blobMasks = p.processorData.getObjectHandle.getData(p.processorData.getProcessorFetchingParams).blobMasks();
            perimeters = bwperim(blobMasks);
        end
% %         
%         function num = getNumSpots(p)
%             num = p.processorDataHolder.processorData.getNumSpots();
%         end
    end
    
end

