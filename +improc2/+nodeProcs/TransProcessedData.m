classdef TransProcessedData < improc2.interfaces.ProcessedData
    
    properties
        needsUpdate = true;
    end
    
    properties (Constant = true)
        dependencyClassNames = {'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'imageSource'};
    end
    
    properties (Dependent = true)
        middlePlane
    end
    
    properties (Access = private)
        storedMiddlePlane = [];
    end
    
    methods
        function pData = TransProcessedData()
        end
        
        function pDataAfterProcessing = run(pData, channelStkContainer)
            img = channelStkContainer.croppedImage;
            if ndims(img) == 3
                sz = size(img);
                middle = floor(sz(3)/2);
                pData.storedMiddlePlane = img(:,:,middle);
            elseif ndims(img) > 3
                error('Image Data must be 3 or less dimensions')
            else
                pData.storedMiddlePlane = img;
            end
            pData.storedMiddlePlane = scale(pData.storedMiddlePlane); 
            pDataAfterProcessing = pData;
        end
        
        function img = getImage(pData, varargin)
            img = pData.storedMiddlePlane;
        end
        
        function middlePlane = get.middlePlane(pData)
            middlePlane = pData.storedMiddlePlane;
        end
        function pData = set.middlePlane(pData, middlePlane)
            pData.storedMiddlePlane = middlePlane;
        end
    end
end

