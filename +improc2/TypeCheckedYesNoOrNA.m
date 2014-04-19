classdef TypeCheckedYesNoOrNA < improc2.interfaces.TypeCheckedValue
    
    properties (SetAccess = private, Dependent = true)
        choices
    end
    properties (Dependent = true)
        value
    end
    properties (Access = private)
        factor
    end
    
    methods
        function p = TypeCheckedYesNoOrNA(initialValue)
            p.factor = improc2.TypeCheckedFactor({'NA', 'yes', 'no'});
            if nargin < 1
                initialValue = 'NA';
            end
            p.value = initialValue;
        end
        function p = set.value(p, val)
            try
                p.factor.value = val;
            catch err
                if strcmp(err.identifier, 'improc2:InvalidValue')
                    error('improc2:InvalidValue', err.message)
                else
                    rethrow(err)
                end
            end 
        end
        function choices = get.choices(p)
            choices = p.factor.choices;
        end
        function val = get.value(p)
            val = p.factor.value;
        end
        function str = valueAsString(p)
            str = p.value;
        end
    end
end

