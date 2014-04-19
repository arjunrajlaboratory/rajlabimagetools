classdef SpotFindingInterface
    
    properties
    end
    
    methods (Abstract = true)
        numSpots = getNumSpots(p)
        [I,J,K] = getSpotCoordinates(p)
    end
    
    methods 
        function p = SpotFindingInterface()
        end
    end
    
end

