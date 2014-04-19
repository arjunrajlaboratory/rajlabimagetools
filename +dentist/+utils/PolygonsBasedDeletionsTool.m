classdef PolygonsBasedDeletionsTool < handle
    %UNTITLED45 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        deletionRequestHandler
        polygonStack
    end
    
    methods
        function p = PolygonsBasedDeletionsTool(polygonStack, deletionRequestHandler)
            p.polygonStack = polygonStack;
            p.deletionRequestHandler = deletionRequestHandler;
            p.setDeletionsToMatchPolygons();
        end
        
        function addPolygon(p, polygon)
            p.polygonStack.addPolygon(polygon);
            p.setDeletionsToMatchPolygons();
        end
        
        function removeLastPolygon(p)
            p.polygonStack.removeLastPolygon();
            p.setDeletionsToMatchPolygons();
        end
        
        function removeAllPolygons(p)
            p.polygonStack.removeAllPolygons();
            p.setDeletionsToMatchPolygons();
        end
        
        function value = getPolygons(p)
            value = p.polygonStack.getPolygons();
        end
        
        % untested
        function setDeletionsToMatchPolygons(p)
            filterFUNC = @(x,y) p.polygonStack.determineIfInAnyPolygon(x,y);
            p.deletionRequestHandler.setDeletionsToMatchXYFilter(filterFUNC);
        end
    end
end

