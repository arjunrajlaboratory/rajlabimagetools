classdef RemovePolygonButton < handle
    %UNTITLED41 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        buttonHandle
        polygonStack
    end
    
    methods
        function p = RemovePolygonButton(polygonStack, buttonHandle)
            p.buttonHandle = buttonHandle;
            p.polygonStack = polygonStack;
        end
        
        function enable(p)
            set(p.buttonHandle, 'CallBack', ...
                @(varargin) p.polygonStack.removeLastPolygon())
            set(p.buttonHandle, 'Enable', 'on')
        end
        
        function disable(p)
            set(p.buttonHandle, 'CallBack', '')
            set(p.buttonHandle, 'Enable', 'off')
        end
    end
    
end

