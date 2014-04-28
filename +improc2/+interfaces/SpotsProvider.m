classdef SpotsProvider
    
    properties
    end
    
    methods (Abstract = true)
        numSpots = getNumSpots(p)
        [I,J,K] = getSpotCoordinates(p)
    end
end

