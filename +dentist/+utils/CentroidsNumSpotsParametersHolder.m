classdef CentroidsNumSpotsParametersHolder < handle
    %UNTITLED26 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        displayParameters
    end
    
    methods
        function p = CentroidsNumSpotsParametersHolder(varargin)
            p.setToDefaults()
            p.set(varargin{:})
        end
        
        function setToDefaults(p)
            p.displayParameters = struct();
            p.displayParameters.FontSize = 12;
            p.displayParameters.xOffset = 0;
            p.displayParameters.yOffset = 0;
        end
        
        function set(p, varargin)
            paramStruct = struct(varargin{:});
            requestedParameters = dentist.utils.updateStruct(...
                p.displayParameters, paramStruct);
            p.displayParameters = requestedParameters;
        end
        
        function value = get(p, propertyName)
            assert(isfield(p.displayParameters, propertyName))
            value = p.displayParameters.(propertyName);
        end
    end
    
end

