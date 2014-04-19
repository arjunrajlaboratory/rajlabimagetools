classdef NotifyingViewportHolder < handle
    
    properties (Access = private)
        viewportHolder
        actionsAfterViewportSetting
    end
    
    methods
        function p = NotifyingViewportHolder(viewportHolder)
            p.viewportHolder = viewportHolder;
            p.actionsAfterViewportSetting = improc2.utils.DependencyRunner();
        end
        
        function viewport = getViewport(p)
            viewport = p.viewportHolder.getViewport();
        end
        
        function setViewport(p, viewport)
            p.viewportHolder.setViewport(viewport)
            p.actionsAfterViewportSetting.runDependencies();
        end
        
        function addActionAfterViewportSetting(p, handleToObject, funcToRunOnIt)
            p.actionsAfterViewportSetting.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
    end
    
end

