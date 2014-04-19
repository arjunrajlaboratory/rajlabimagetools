classdef MockParameterGrabbingDisplayer < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        parametersHolder
        paramToGrab
        paramGrabbedOnDraw
        timesDeactivated = 0;
        timesDrawn = 0;
    end
    
    methods
        function p = MockParameterGrabbingDisplayer(parametersHolder, paramToGrab)
            p.parametersHolder = parametersHolder;
            p.paramToGrab = paramToGrab;
        end
        function draw(p)
            p.paramGrabbedOnDraw = p.parametersHolder.get(p.paramToGrab);
            p.timesDrawn = p.timesDrawn + 1;
        end
        function deactivate(p)
            p.timesDeactivated = p.timesDeactivated + 1;
        end
    end
    
end

