classdef MinimalProcessorManager < improc2.DataChangeTrackedProcStack
    %UNTITLED12 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function p = MinimalProcessorManager()
        end
    end
    
    methods (Access = protected)
        function p = actionOnDataChangeAt(p, indexOfModifiedProc)
            fprintf(1,['Detected data change in Processor at Position ',...
                num2str(indexOfModifiedProc),'\n']);
        end
    end
    
end

