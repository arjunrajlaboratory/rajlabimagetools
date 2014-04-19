classdef InteractiveValue < handle
    
    properties (GetAccess = protected, SetAccess = private);
        itemName
        annotationsHandle
        uih
    end
    
    properties (Dependent = true, Access = protected)
        value
    end
    
    methods
        function p = InteractiveValue(itemName, annotationsHandle, uihandle)
            p.itemName = itemName;
            p.annotationsHandle = annotationsHandle;
            p.attachUIControl(uihandle);
        end
        
        function value = get.value(p)
            value = p.annotationsHandle.getValue(p.itemName);
        end
        
        function set.value(p, value)
            p.annotationsHandle.setValue(p.itemName, value)
            p.update();
        end
        
        function attachUIControl(p, uihandle)
            p.throwErrorIfIncompatibleUIStyle(uihandle)
            p.setupUIControl(uihandle);
            p.uih = uihandle;
            p.update();
        end
        
        function update(p)
            if ishandle(p.uih)
                p.syncWithUI()
            else
                p.doIfUIHandleIsInvalid();
            end
        end
    end
    
    methods (Access = protected, Abstract = true)
        syncWithUI(p)
        throwErrorIfIncompatibleUIStyle(p, uihandle)
        setupUIControl(p, uihandle)
    end
    
    methods (Access = private)
        function doIfUIHandleIsInvalid(p)
        end
    end
    
end

