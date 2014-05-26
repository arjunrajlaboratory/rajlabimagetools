classdef TypeCheckedFactor < improc2.interfaces.TypeCheckedValue
    
    properties (SetAccess = private)
        choices
    end
    
    properties
        value
    end
    
    methods
        function p = TypeCheckedFactor(choices, initValue)
            assert(iscell(choices) && ~isempty(choices) && ...
                all(cellfun(@isstr, choices)), 'improc2:BadArguments', ...
                'First input must be a nonempty cell array of strings')
            assert(length(choices(:)) == length(unique(choices(:))), ...
                'improc2:ChoiceExists', 'input choices contained repeated values')
            p.choices = choices(:)';
            if nargin < 2
                initValue = choices{1};
            end
            p.value = initValue;
        end
        
        function p = set.value(p, val)
            p.throwErrorIfInvalidValue(val)
            p.value = val;
        end
        
        function p = addChoice(p, choice)
            assert(ischar(choice), 'improc2:BadArguments', ...
                'New choice must be a string (see ischar)')
            assert(~any(strcmp(choice, p.choices)), 'improc2:ChoiceExists',...
                'Choice %s already exists.', choice)
            p.choices = [p.choices, {choice}];
        end
        
        function str = valueAsString(p)
            str = p.value;
        end
    end
    
    methods (Access = protected)
        function throwErrorIfInvalidValue(p, value)
            assert(ischar(value), 'improc2:InvalidValue', ...
                'value must be a string (see ischar)')
            assert(any(strcmp(value, p.choices)), 'improc2:InvalidValue', ...
                'value must be one of: %s', improc2.utils.stringJoin(p.choices, ', '))
        end
    end
    
end

