classdef KeyPressInterpreter < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        controlDown
        axesManager
    end
    
    methods
        function p = KeyPressInterpreter(figH)
           set(figH, 'KeyPressFcn',{@keyPressCallBack,p});
           set(figH, 'KeyReleaseFcn', {@keyReleaseCallBack,p});
           p.controlDown = false;
        end
        function keyPressCallBack(hObject, eventData,p)
           switch(eventData.Key)
               case 'control'
                   p.controlDown = true;
               case 'uparrow'
                   p.axesManager.moveVertical(-1);
               case 'downarrow'
                   p.axesManager.moveVertical(1);
               case 'rightarrow'
                   p.axesManager.moveHorizontal(1);
               case 'leftarrow'
                   p.axesManager.moveHorizontal(-1);
           end
        end
        function setAxesManager(p, axesManager)
            p.axesManager = axesManager;
        end
        function keyReleaseCallBack(hObject, eventData,p)
            if strcmp(eventData.Key,'control')
                p.controlDown = false;
            end
        end
    end
    
end

