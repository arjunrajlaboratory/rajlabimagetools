classdef TypeCheckedLogical < improc2.interfaces.TypeCheckedValue
    
    properties (SetAccess = private)
        choices = [true, false];
    end
    properties
        value
    end
    
    methods
        function p = TypeCheckedLogical(initValue)
            if nargin < 1
                initValue = true;
            end
            p.value = initValue;
        end
        
        function p = set.value(p, val)
            p.throwErrorIfInvalidValue(val)
            p.value = val;
        end
        
        function str = valueAsString(p)
            if p.value
                str = 'true';
            else
                str = 'false';
            end
        end
    end
    
    methods (Access = protected)
        function throwErrorIfInvalidValue(p, value)
            assert(islogical(value) && isscalar(value), ...
                'improc2:InvalidValue', 'value must be a scalar logical (true or false)')
        end
    end
    
end

