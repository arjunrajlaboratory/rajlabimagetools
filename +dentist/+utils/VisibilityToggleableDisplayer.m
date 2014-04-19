classdef VisibilityToggleableDisplayer < dentist.utils.AbstractDisplayer
    
    properties (SetAccess = private)
        visible = true;
    end
    
    properties (SetAccess = private, GetAccess = private)
        displayer;
        visibilityUIControl;
        isActive = false;
    end
    
    methods
        function p = VisibilityToggleableDisplayer(displayer)
            p.displayer = displayer;
        end
        
        function draw(p)
            p.isActive = true;
            if p.visible
                p.displayer.draw()
            end
        end
        
        function deactivate(p)
            p.isActive = false;
            p.displayer.deactivate()
        end
        
        function setVisibilityAndDrawIfActive(p, visibility)
            assert(islogical(visibility) && isscalar(visibility))
            p.visible = visibility;
            p.syncWithVisibilityUI();
            if p.isActive && ~p.visible
                p.displayer.deactivate()
            elseif p.isActive && p.visible
                p.displayer.draw()
            end
        end
        
        function syncWithVisibilityUI(p)
            if ~isempty(p.visibilityUIControl) && ishandle(p.visibilityUIControl)
                set(p.visibilityUIControl, 'Value', p.visible)
            end
        end
        
        function attachVisibilityUIControl(p, uihandle)
            assert(ishandle(uihandle), 'input uihandle must be a handle to a uicontrol')
            p.visibilityUIControl = uihandle;
            set(p.visibilityUIControl, 'Max', true, 'Min', false);
            set(p.visibilityUIControl, 'Value', p.visible);
            set(p.visibilityUIControl, 'Callback', @p.visibilityUIControlCallback)
        end
        
        function visibilityUIControlCallback(p, varargin)
            p.setVisibilityAndDrawIfActive(logical(get(p.visibilityUIControl, 'Value')));
        end
    end
    
end

