classdef ImageObjectBaseData
    
    properties (Dependent = true)
        imfilemask
        mask
        boundingbox
    end
    
    properties (Access = private)
        storedImageFileMask = [];
    end
    
    methods
        function imfilemask = get.imfilemask(p)
            imfilemask = p.storedImageFileMask;
        end
        function p = set.imfilemask(p, imfilemask)
            p.storedImageFileMask = imfilemask;
        end
        function bbox = get.boundingbox(pData)
            s = regionprops(pData.storedImageFileMask, 'BoundingBox');
            bbox = s.BoundingBox;
            bbox(1:2) = bbox(1:2) + 0.5; % Move corner of box to center of pixel
            bbox(3:4) = bbox(3:4) - 1; % Shrink box size by 1 pixel (i.e., 0.5 on each side)
        end
        function mask = get.mask(pData)
            mask = imcrop(pData.storedImageFileMask, pData.boundingbox);
        end
    end
end

