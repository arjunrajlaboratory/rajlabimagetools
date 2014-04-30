classdef TransProcessedData < improc2.interfaces.ProcessedData
    
    properties
        needsUpdate = true;
    end
    
    properties (Constant = true)
        dependencyClassNames = {'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'imageSource'};
    end
    
    properties (Access = private)
        middlePlane = [];
    end
    
    methods
        function pData = TransProcessedData()
        end
        
        function pDataAfterProcessing = run(pData, channelStkContainer)
            img = channelStkContainer.croppedImage;
            if ndims(img) == 3
                sz = size(img);
                middle = floor(sz(3)/2);
                pData.middlePlane = img(:,:,middle);
            elseif ndims(img) > 3
                error('Image Data must be 3 or less dimensions')
            else
                pData.middlePlane = img;
            end
            pData.middlePlane = scale(pData.middlePlane); 
            pDataAfterProcessing = pData;
        end
        
        function img = getImage(pData, varargin)
            img = pData.middlePlane;
        end
    end
end

