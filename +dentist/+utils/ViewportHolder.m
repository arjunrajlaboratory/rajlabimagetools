classdef ViewportHolder < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        viewport
    end
    
    methods
        function p = ViewportHolder(viewport)
           p.viewport = viewport; 
        end
        
        function viewport = getViewport(p)
            viewport = p.viewport;
        end
        
        function setViewport(p, viewport)
            p.viewport = viewport;
        end
    end
    
end

