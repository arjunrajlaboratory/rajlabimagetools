classdef MockVisibilityToggleable < handle
    %UNTITLED37 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        isVisible = false;
        timesDrawn = 0;
    end
    
    methods
        function setVisibilityAndDrawIfActive(p, value)
            p.isVisible = value;
        end
        function draw(p)
            p.timesDrawn = p.timesDrawn + 1;
        end
    end
    
end

