classdef AnnotationGUILauncher < handle
    
    properties (Access = private)
        annotationsHandle
        keyPressCallbackFuncHandle
        guiFigH
    end
    
    methods
        function p = AnnotationGUILauncher(annotationsHandle, keyPressCallbackFuncHandle)
            if nargin < 2
                keyPressCallbackFuncHandle = @improc2.utils.doNothing;
            end
            p.annotationsHandle = annotationsHandle;
            p.keyPressCallbackFuncHandle = keyPressCallbackFuncHandle;
        end
        function launchGUI(p)
            if ~isempty(p.guiFigH) && ishandle(p.guiFigH)
                figure(p.guiFigH);
            else
                p.guiFigH = improc2.launchAnnotationsGUI(p.annotationsHandle);
                set(p.guiFigH, 'KeyPressFcn', p.keyPressCallbackFuncHandle)
            end
        end
    end
end

