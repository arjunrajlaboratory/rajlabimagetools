classdef DeletionsSubsystem < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        notifyingDeleter
        polygonBasedDeletionsTool
    end
    
    methods
        function p = DeletionsSubsystem(notifyingDeleter, polygonBasedDeletionsTool)
            p.notifyingDeleter = notifyingDeleter;
            p.polygonBasedDeletionsTool = polygonBasedDeletionsTool;
        end
        
        function addPolygon(p, polygon)
            p.polygonBasedDeletionsTool.addPolygon(polygon);
        end
        
        function removeLastPolygon(p)
            p.polygonBasedDeletionsTool.removeLastPolygon();
        end
        
        function removeAllPolygons(p)
            p.polygonBasedDeletionsTool.removeAllPolygons();
        end
        
        function val = getPolygons(p)
            val = p.polygonBasedDeletionsTool.getPolygons();
        end
        
        function addActionAfterDeletion(p, handleToObject, funcToRunOnIt)
           p.notifyingDeleter.addActionAfterDeletion(handleToObject, funcToRunOnIt) 
        end
    end
    
end

