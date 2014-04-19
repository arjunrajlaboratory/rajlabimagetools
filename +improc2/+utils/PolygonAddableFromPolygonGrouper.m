classdef PolygonAddableFromPolygonGrouper < handle
    
    properties (Access = private)
        polygonBasedGrouper
    end
    
    methods
        function p = PolygonAddableFromPolygonGrouper(polygonBasedGrouper)
            p.polygonBasedGrouper = polygonBasedGrouper;
        end
        
        function addPolygon(p, polygon)
            p.polygonBasedGrouper.groupAllInPolygon(polygon);
        end
    end
    
end

