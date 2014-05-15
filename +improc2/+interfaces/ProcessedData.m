classdef ProcessedData < improc2.interfaces.NodeData
    
    properties (Abstract = true)
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
