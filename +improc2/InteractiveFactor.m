classdef InteractiveFactor < improc2.interfaces.InteractiveValue
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Dependent = true)
        choices
    end
    
    
    methods
        function p = InteractiveFactor(itemName, annotationsHandle, uihandle)
            p = p@improc2.interfaces.InteractiveValue(...
                itemName, annotationsHandle, uihandle);
        end
        
        function choices = get.choices(p)
            choices = p.annotationsHandle.getChoices(p.itemName);
        end
        
        function callback(p)
            p.value = p.choices{get(p.uih, 'Value')};
        end 
    end
    
    methods (Access = protected)
        function syncWithUI(p)
            set(p.uih, 'Value', find(strcmp(p.value, p.choices)))
        end
        function throwErrorIfIncompatibleUIStyle(p, uihandle)
            assert(strcmp(get(uihandle,'Style'), 'popupmenu'), ...
                'improc2:BadArguments', 'Factors can only be attached to popupmenus')
        end
        function setupUIControl(p, uihandle)
            set(uihandle, 'String', p.choices);
            set(uihandle, 'Callback', @(varargin) p.callback());
        end
    end
    
end

