classdef InteractiveString < improc2.interfaces.InteractiveValue
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    
    methods
        function p = InteractiveString(itemName, annotationsHandle, uihandle)
            p = p@improc2.interfaces.InteractiveValue(...
                itemName, annotationsHandle, uihandle);
        end
        
        function callback(p)
            p.value = get(p.uih, 'String');
        end
    end
    
    methods (Access = protected)
        function syncWithUI(p)
            set(p.uih, 'String', p.value)
        end
        function throwErrorIfIncompatibleUIStyle(p, uihandle)
            assert(strcmp(get(uihandle,'Style'), 'edit'), 'improc2:BadArguments', ...
                'Strings must be attached to Style = edit uicontrols')
        end
        function setupUIControl(p, uihandle)
            set(uihandle, 'Callback', @(varargin) p.callback())
            set(uihandle, 'Max', 1, 'Min', 1) % Max-Min < 1 makes it a single line textbox
        end
    end
end

