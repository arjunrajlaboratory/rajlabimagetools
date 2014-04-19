classdef TypeCheckedValue
    
    properties (Abstract = true, SetAccess = private)
        choices
    end
    properties (Abstract = true)
        value
    end
    
    methods (Abstract = true)
        strout = valueAsString(p)
    end
end

