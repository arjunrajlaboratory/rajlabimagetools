classdef TypeCheckedString < improc2.interfaces.TypeCheckedValue
    
    properties (SetAccess = private)
        choices = 'any string';
    end
    properties
        value
    end
    
    methods
        function p = TypeCheckedString(initValue)
            if nargin < 1
                initValue = '';
            end
            p.value = initValue;
        end
        
        function p = set.value(p, val)
            p.throwErrorIfInvalidValue(val)
            p.value = val;
        end
        function str = valueAsString(p)
            str = p.value;
        end
    end
    
    methods (Access = protected)
        function throwErrorIfInvalidValue(p, value)
            assert(ischar(value), 'improc2:InvalidValue',...
                'Value must be a string (see ischar)')
        end
    end
    
end

