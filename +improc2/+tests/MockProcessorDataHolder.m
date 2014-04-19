classdef MockProcessorDataHolder < handle
    
    properties 
        processorData
    end
    
    methods
        function p = MockProcessorDataHolder(procData)
            p.processorData = procData;
        end
    end
    
end

