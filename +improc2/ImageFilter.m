classdef ImageFilter

    properties
        filterParams = improc2.ParamList(); 
    end
    
    methods
        function imout = applyFilter(p, imin)
            imout = imin;
        end
    end
    
    methods
        function p = ImageFilter(filterParams)
            if nargin ~= 0
                p.filterParams = p.filterParams.replaceParams(filterParams);
            end
        end
    end
end

