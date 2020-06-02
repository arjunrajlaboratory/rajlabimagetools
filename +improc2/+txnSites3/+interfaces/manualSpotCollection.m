classdef manualSpotCollection
    
    properties
    end
    
    methods (Abstract = true)
        addClickedSpot(p, x, y)
        [X, Y, Z] = getClickedSpotCoordinates(p)
        Int = getNearbyIntensities(p)
        deleteClickedSpot(p,pointID)
        moveClickedSpot(p,pointID,newX,newY)
    end
end

