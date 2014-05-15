classdef MockColocolizerData < improc2.interfaces.ProcessedData
    
    properties
        needsUpdate = true;
    end
    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.SpotsProvider', ...
            'improc2.interfaces.SpotsProvider'};
        dependencyDescriptions = {'spots source A', 'spots source B'};
    end
    
    properties
        numSpotsA
        numSpotsB
    end
    
    methods
        function pData = MockColocolizerData()
        end
        function pData = run(pData, spotsProviderA, spotsProviderB)
            pData.numSpotsA = spotsProviderA.getNumSpots();
            pData.numSpotsB = spotsProviderB.getNumSpots();
        end
    end    
end
