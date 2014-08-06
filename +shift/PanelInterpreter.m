classdef PanelInterpreter < shift.MouseGestureInterpreter
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        axesHandle
        axesManager
    end
    
    methods
        function p = PanelInterpreter(axesManager, axesHandle)
            p.axesManager = axesManager;
            p.axesHandle = axesHandle;
        end
        function moveCallback(p, varargin)
        end
        
        function doAfterButtonUp(p)
        end
        
        function doOnButtonDown(p)
            clickLocation = get(p.axesHandle,'CurrentPoint');
            row = clickLocation(1,2);
            col = clickLocation(1,1);
            display('Clicked!');
            p.axesManager.registerClick([row, col]);
        end
    end
    
end

