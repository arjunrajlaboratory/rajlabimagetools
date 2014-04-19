classdef MockImageHolder < handle
    
    properties (Access = private)
        img
    end
    
    methods
        function p = MockImageHolder(img)
            p.img = img;
        end
        function img = getImage(p)
            img = p.img;
        end
        function setImage(p, img)
            p.img = img;
        end
    end
    
end

