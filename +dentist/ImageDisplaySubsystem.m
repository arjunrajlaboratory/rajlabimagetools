classdef ImageDisplaySubsystem < handle
    
    properties (SetAccess = private, GetAccess = private)
    %properties (SetAccess = public, GetAccess = public)
        viewportHolder
        thumbnailDisplayer
        mainWindowDisplayer
        actionsAfterViewportUpdate;
    end
    
    methods
        function p = ImageDisplaySubsystem(viewportHolder, ...
                mainWindowDisplayer, thumbnailDisplayer)
            p.viewportHolder = viewportHolder;
            p.mainWindowDisplayer = mainWindowDisplayer;
            p.thumbnailDisplayer = thumbnailDisplayer;
            p.actionsAfterViewportUpdate = improc2.utils.DependencyRunner();
        end
        
        function draw(p)
            p.thumbnailDisplayer.draw();
            p.mainWindowDisplayer.draw();
        end
        
        function viewport = getViewport(p)
            viewport = p.viewportHolder.getViewport();
        end
        
        function setViewport(p, viewport)
            p.viewportHolder.setViewport(viewport);
            p.draw();
            p.actionsAfterViewportUpdate.runDependencies();
        end
        
        function addActionAfterViewportUpdate(p, handleToObject, funcToRunOnIt)
            p.actionsAfterViewportUpdate.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        function thumbnailViewport = getThumbnailViewport(p)
            viewport = p.getViewport();
            thumbnailViewport = p.thumbnailDisplayer.convertToThumbnailViewport(...
                viewport);
        end
        
        function setThumbnailViewport(p, thumbnailViewport)
            viewport = p.getViewport();
            viewport = viewport.setToMatchViewport(thumbnailViewport);
            p.setViewport(viewport);
        end
    end
    
end

