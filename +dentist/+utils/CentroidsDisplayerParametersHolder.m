classdef CentroidsDisplayerParametersHolder < handle
    %UNTITLED26 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        displayParameters
    end
    
    methods
        function p = CentroidsDisplayerParametersHolder(varargin)
            p.setToDefaults()
            p.set(varargin{:})
        end
        
        function setToDefaults(p)
            p.displayParameters = struct();
            p.displayParameters.circleRadius = 60;
            p.displayParameters.spotsOrCircles = 'spots';
        end
        
        function set(p, varargin)
            paramStruct = struct(varargin{:});
            requestedParameters = dentist.utils.updateStruct(...
                p.displayParameters, paramStruct);
            assert(ismember(requestedParameters.spotsOrCircles, ...
                {'spots', 'circles'}), ...
                'spotsOrCircles must be set to spots or circles')
            p.displayParameters = requestedParameters;
        end
        
        function value = get(p, propertyName)
            assert(isfield(p.displayParameters, propertyName))
            value = p.displayParameters.(propertyName);
        end
    end
    
end

