classdef TypeCheckedNumeric < improc2.interfaces.TypeCheckedValue

    properties (SetAccess = private)
        choices = 'any numeric';
    end
    properties
        value
    end
    
    methods
        function p = TypeCheckedNumeric(initValue)
            if nargin < 1
                initValue = 0;
            end
            p.value = initValue;
        end
        
        function p = set.value(p, val)
            p.throwErrorIfInvalidValue(val)
            p.value = val;
        end
        
        function str = valueAsString(p)
            str = num2str(p.value);
        end
    end
    
    methods (Access = protected)
        function throwErrorIfInvalidValue(p, value)
            assert(isnumeric(value) && isscalar(value), 'improc2:InvalidValue',...
                'Value must be a scalar number (0, 1, pi, 10^4, etc.))')
        end
    end
    
end

