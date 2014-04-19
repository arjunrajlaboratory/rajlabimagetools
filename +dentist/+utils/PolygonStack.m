classdef PolygonStack < handle
    %UNTITLED18 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        polygonsCellArray = {};
    end
    
    methods
        function addPolygon(p, polygon)
            p.polygonsCellArray = [p.polygonsCellArray, {polygon}];
        end
        
        function removeLastPolygon(p)
           if ~isempty(p.polygonsCellArray)
               p.polygonsCellArray = p.polygonsCellArray(1:(end-1)); 
           end
        end
        
        function removeAllPolygons(p)
            p.polygonsCellArray = {};
        end
            
        
        function inAnyPolygon = determineIfInAnyPolygon(p, xs, ys)  
            inAnyPolygon = false(size(xs));
            for i = 1:length(p.polygonsCellArray)
                polygon = p.polygonsCellArray{i};
                inAnyPolygon = inAnyPolygon | ...
                    inpolygon(xs, ys, polygon(:,1), polygon(:,2));
            end
        end
        
        function polygonsCellArray = getPolygons(p)
            polygonsCellArray = p.polygonsCellArray;
        end
    end
    
end

