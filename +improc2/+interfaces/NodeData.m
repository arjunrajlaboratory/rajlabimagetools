classdef NodeData

    properties (Abstract = true)
        needsUpdate
    end
    properties (Abstract = true, Constant = true)
        dependencyClassNames
        dependencyDescriptions
    end
    
end