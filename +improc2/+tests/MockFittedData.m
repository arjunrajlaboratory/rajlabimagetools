classdef MockFittedData < improc2.interfaces.ProcessedData & improc2.interfaces.SpotsProvider
    
    properties
        needsUpdate = true;
    end
    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.SpotsProvider', ...
            'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'initial Spot Guesses', 'image source'};
    end
    
    properties (Access = private)
        numSpots
    end
    
    methods
        function pData = MockFittedData()
        end
        function pData = run(pData, spotsProvider, stackContainer)
            pData.numSpots = spotsProvider.getNumSpots();
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
