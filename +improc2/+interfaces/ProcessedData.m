classdef ProcessedData
    
    properties (Abstract = true)
        isProcessed
        needsUpdate
    end
    
    methods (Abstract = true)
        pDataAfterProcessing = run(pData, varargin)
    end
    
end

