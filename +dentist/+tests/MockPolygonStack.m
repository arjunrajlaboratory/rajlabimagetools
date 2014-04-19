classdef MockPolygonStack < handle
    %UNTITLED39 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function p = MockPolygonStack()
        end
        
        function addPolygon(p, XsAndYs)
            fprintf('addPolygon called with argument of size:\n')
            disp(size(XsAndYs))
        end
        
        function removeLastPolygon(p)
            fprintf('requested remove Last Polygon\n')
        end
        
        function removeAllPolygons(p)
            fprintf('requested remove All Polygons\n')
        end
        
        function val = getPolygons(p)
            val = {};
            fprintf('requested getPolygons')
        end
    end
    
end

