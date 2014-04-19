classdef PolygonAddingMouseInterpreter < dentist.utils.FreeHandDrawingInterpreter
    %UNTITLED38 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        polygonStack
    end
    
    methods
        function p = PolygonAddingMouseInterpreter(polygonStack)
            p.polygonStack = polygonStack;
        end
        
        % override
        function doAfterButtonUp(p, varargin)
            p.doAfterButtonUp@dentist.utils.FreeHandDrawingInterpreter(varargin{:});
            polygon = [p.polygonXs(:), p.polygonYs(:)];
            p.polygonStack.addPolygon(polygon);
        end
    end
    
end

