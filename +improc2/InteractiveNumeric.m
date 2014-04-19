classdef InteractiveNumeric < improc2.interfaces.InteractiveValue;
    
    methods
        function p = InteractiveNumeric(itemName, annotationsHandle, uihandle)
            p = p@improc2.interfaces.InteractiveValue(...
                itemName, annotationsHandle, uihandle);
        end
        
        function callback(p)
            p.value = str2num(get(p.uih, 'String'));
        end
    end
    
    methods (Access = protected)
        function syncWithUI(p)
            set(p.uih, 'String', num2str(p.value))
        end
        function throwErrorIfIncompatibleUIStyle(p, uihandle)
            assert(strcmp(get(uihandle,'Style'), 'edit'), 'improc2:BadArguments', ...
                'Numeric can be attached to edit boxes only')
        end
        function setupUIControl(p, uihandle)
            set(uihandle, 'Callback', @(varargin) p.callback())
        end
    end
end

