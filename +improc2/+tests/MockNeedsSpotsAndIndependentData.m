classdef MockNeedsSpotsAndIndependentData < improc2.interfaces.ProcessedData
    
    properties
        needsUpdate = true;
    end
    properties (SetAccess = private)
        numSpots
    end
    
    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.SpotsProvider', ...
            'improc2.tests.MockNoDependentsData'};
        dependencyDescriptions = {'spots', 'other data'};
    end
    
    methods
        function p = MockNeedsSpotsAndIndependentData()
        end
        
        function numSpots = getNumSpots(p)
            numSpots = p.numSpots;
        end
        
        function p = run(p, spotsProvider, valueProvider)
            p.numSpots = getNumSpots(spotsProvider) * valueProvider.value;
        end
    end
    
end

