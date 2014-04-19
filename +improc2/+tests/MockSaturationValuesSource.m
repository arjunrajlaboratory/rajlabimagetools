classdef MockSaturationValuesSource < handle
    
    properties (Access = private)
        value
    end
    
    methods
        function p = MockSaturationValuesSource(value)
            p.value = value;
        end
        
        function setSaturationValue(p, value)
            p.value = value;
        end
        
        function value = getSaturationValue(p)
            value = p.value;
        end
    end
    
end

