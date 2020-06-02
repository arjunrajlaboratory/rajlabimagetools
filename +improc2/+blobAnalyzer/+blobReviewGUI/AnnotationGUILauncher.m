classdef AnnotationGUILauncher < handle
    
    properties (Access = private)
        annotationsHandle
        keyPressCallbackFuncHandle
        guiFigH
        isActive = false;
    end
    
    methods
        function p = AnnotationGUILauncher(annotationsHandle, keyPressCallbackFuncHandle)
            if nargin < 2
                keyPressCallbackFuncHandle = @improc2.utils.doNothing;
            end
            p.annotationsHandle = annotationsHandle;
            p.keyPressCallbackFuncHandle = keyPressCallbackFuncHandle;
        end
        function figureCloseRequest(p, varargin)
            p.isActive = false;
            delete(p.guiFigH)
        end
        function launchGUI(p)
            if p.isActive
                figure(p.guiFigH);
            else
                p.guiFigH = improc2.launchAnnotationsGUI(p.annotationsHandle);
                set(p.guiFigH, 'KeyPressFcn', p.keyPressCallbackFuncHandle)
                set(p.guiFigH, 'CloseRequestFcn', @(varargin) p.figureCloseRequest())
                p.isActive = true;
            end
        end
    end
end

