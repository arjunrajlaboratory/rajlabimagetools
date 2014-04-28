classdef ProcessedData
    
    properties (Abstract = true)
        isProcessed
        needsUpdate
    end
    properties (Abstract = true, Constant = true)
        dependencyClassNames
        dependencyDescriptions
    end
    
    methods (Abstract = true)
        pDataAfterProcessing = run(pData, varargin)
    end
    
end

