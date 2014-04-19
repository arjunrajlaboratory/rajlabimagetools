classdef InteractiveLogical < improc2.interfaces.InteractiveValue
    %UNTITLED26 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function p = InteractiveLogical(itemName, annotationsHandle, uihandle)
            p = p@improc2.interfaces.InteractiveValue(...
                itemName, annotationsHandle, uihandle);
        end
        
        function callback(p)
            p.value = logical(get(p.uih, 'Value'));
        end
        
    end
    
    methods (Access = protected)
        function syncWithUI(p)
            set(p.uih, 'Value', p.value)
        end
        function throwErrorIfIncompatibleUIStyle(p, uihandle)
            assert(strcmp(get(uihandle,'Style'), 'checkbox'), 'improc2:BadArguments', ...
                'Logicals can be attached to checkboxes only')
        end
        function setupUIControl(p, uihandle)
            set(uihandle, 'Max', true, 'Min', false)
            set(uihandle, 'Callback', @(varargin) p.callback())
        end
    end
end

