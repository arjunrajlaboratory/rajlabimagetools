classdef MockPolygonBasedGrouper < handle

    properties (SetAccess = private)
        mostRecentPolygon;
    end
    
    methods
        function groupAllInPolygon(p, polygon)
            p.mostRecentPolygon = polygon;
        end
    end
    
end

