classdef MockManualSpotsData < improc2.interfaces.NodeData & improc2.interfaces.SpotsProvider
    
    properties
        needsUpdate = false;
    end
    properties (Constant = true)
        dependencyClassNames = {'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'image source'};
    end
    
    properties
        numSpots
    end
    
    methods
        function pData = MockManualSpotsData()
        end
        function numSpots = getNumSpots(p)
            numSpots = p.numSpots;
        end
        function [I,J,K] = getSpotCoordinates(p)
            I = ones(1, p.numSpots);
            J = ones(1, p.numSpots);
            K = ones(1, p.numSpots);
        end
    end
end

