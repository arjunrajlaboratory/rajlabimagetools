classdef ImageObjectBaseData
    
    properties (Dependent = true)
        imageFileMask
    end
    
    properties (Access = private)
        storedImageFileMask = [];
    end
    
    methods
        function imageFileMask = get.imageFileMask(p)
            imageFileMask = p.storedImageFileMask;
        end
        function p = set.imageFileMask(p, imageFileMask)
            p.storedImageFileMask = imageFileMask;
        end
    end
end

