classdef MockNoDependentsData < improc2.interfaces.NodeData
    
    properties
        needsUpdate = false;
    end
    properties
        value
    end
    
    properties (Constant = true)
        dependencyClassNames = {};
        dependencyDescriptions = {};
    end
    
    methods
        function p = MockNoDependentsData()
        end
    end
end

