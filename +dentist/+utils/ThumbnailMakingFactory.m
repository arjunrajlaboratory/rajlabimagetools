classdef ThumbnailMakingFactory < handle
    %UNTITLED14 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        thumbnailMakers
        actionsAfterMakingThumbnails;
    end
    
    methods
        function p = ThumbnailMakingFactory(thumbnailMakers)
            p.thumbnailMakers = thumbnailMakers;
            p.actionsAfterMakingThumbnails = improc2.utils.DependencyRunner();
        end
        
        function makeAllThumbnails(p)
            fprintf('Making Thumbnails ...\n')
            p.thumbnailMakers.applyForEachChannel(@makeAndStore);
            fprintf('Done making thumbnails.\n')
            p.actionsAfterMakingThumbnails.runDependencies();
        end
         
        function setThumbnailWidthAndHeight(p, width, height)
            p.thumbnailMakers.applyForEachChannel(...
                @(x) x.setThumbnailWidthAndHeight(width, height));
        end
        
        function setPixelExpansionSize(p, expandedPixelSideLengthInImage)
            p.thumbnailMakers.applyForEachChannel(...
                @(x) x.setPixelExpansionSize(expandedPixelSideLengthInImage));
        end
        
        function addActionAfterMakingThumbnails(p, handleToObject, funcToRunOnIt)
            p.actionsAfterMakingThumbnails.registerDependency(...
                handleToObject, funcToRunOnIt)
        end
    end
end

