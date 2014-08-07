classdef BorderCheck
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        borderCheckH
        imageProvider
        axesManager
    end
    
    methods
        function p = BorderCheck(borderCheckH, imageProvider, axesManager)
            p.borderCheckH = borderCheckH;
            p.imageProvider = imageProvider;
            p.axesManager = axesManager;
           set(borderCheckH, 'Callback', {@borderCheckCallback,p});
        end
        function borderCheckCallback(hObject, eventData, p)
            p.axesManager.displayImage();
        end
    end
    
end

