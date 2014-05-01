classdef ParamList
    % An object that can contain named properties and a method for replacing existing values of those properties using a structure.

    properties (SetAccess = 'protected')
    end
    
    methods (Sealed = true)
        function p = replaceParams(p, param_struct)
            assert(isa(param_struct, 'struct') || isa(param_struct, 'improc2.ParamList'),...
                'Parameter replacement must be a struct')
            
            paramNames = fields(param_struct);
            for paramNum = 1:length(paramNames)
                param = paramNames{paramNum};
                try
                    p.(param) = param_struct.(param);
                catch
                    error([param, ' is not a Parameter in this ParameterList']);
                end
            end
        end
    end
    
    methods
        function p = ParamList(param_struct)
            if nargin ~= 0
                p = p.replaceParams(param_struct);
            end
        end
        
    end
    
end

