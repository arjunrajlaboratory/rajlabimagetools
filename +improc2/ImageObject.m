classdef ImageObject
    
    properties
        processors
        annotations = struct('isGood', improc2.TypeCheckedLogical(true));
        metadata = struct();
    end
    
    properties (SetAccess = protected)
        object_mask = struct();
        dirPath
    end
    
    methods
        function p = ImageObject(imFileMask, imagenumber, dirPath)
            p.processors = improc2.MultiChannelProcManager(imagenumber, dirPath);
            p = p.setObjImFileMaskTo(imFileMask);
            p.dirPath = dirPath;
        end
    
        function p = setObjImFileMaskTo(p, mask)
            s = regionprops(mask,'BoundingBox');
            bb = s.BoundingBox;
            bb(1:2) = bb(1:2) + 0.5; % Move corner of box to center of pixel
            bb(3:4) = bb(3:4) - 1; % Shrink box size by 1 pixel (i.e., 0.5 on each side)
            
            p.object_mask.imfilemask = mask;
            p.object_mask.mask = imcrop(mask,bb);
            p.object_mask.boundingbox = bb;
        end
    end 
end
    

