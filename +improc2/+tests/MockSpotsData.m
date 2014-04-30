classdef MockSpotsData < improc2.interfaces.ProcessedData & improc2.interfaces.SpotsProvider
    
    properties
        needsUpdate = true;
    end
    properties (Constant = true)
        dependencyClassNames = {'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'image source'};
    end
    
    properties (Access = private)
        numSpots
    end
    
    methods
        function pData = MockSpotsData(numSpots)
            if nargin < 1
                numSpots = 0;
            end
            pData.numSpots = numSpots;
        end
        function pData = run(pData, stackContainer)
            % test that these attributes exist;
            stackContainer.croppedImage;
            stackContainer.croppedMask;
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

