classdef ThumbnailDisplayer < dentist.utils.AbstractDisplayer
    % Scales an incoming viewport
    
    properties (GetAccess = private, SetAccess = private)
        imageArray
        channelHolder
        thumbnailSize
        axH
        imageH
        rectangleH
        optionalGraphicsParameters
        viewportHolder
    end
    
    
    
    
    methods
        function p = ThumbnailDisplayer(axH, imgByChannelArray, channelHolder,...
                viewportHolder, varargin)
            p.axH = axH;
            p.imageArray = imgByChannelArray;
            p.channelHolder = channelHolder;
            p.viewportHolder = viewportHolder;
            channelName = p.channelHolder.getChannelName();
            p.thumbnailSize = size(p.imageArray.getByChannelName(channelName));
            p.optionalGraphicsParameters = varargin;
        end
        
        function viewport = convertToThumbnailViewport(p, viewportForOtherImage)
            viewport = dentist.utils.makeImageViewportScaledToImageSize(...
                viewportForOtherImage, p.thumbnailSize(2), p.thumbnailSize(1));
        end
        
        function draw(p)
            
            viewportForSomeOtherImage = p.viewportHolder.getViewport();
            channelName = p.channelHolder.getChannelName();
            
            viewport = p.convertToThumbnailViewport(viewportForSomeOtherImage);
            img = p.imageArray.getByChannelName(channelName);
            set(p.axH, 'XLim', [0.5, viewport.imageWidth + 0.5], ...
                'YLim', [0.5, viewport.imageHeight + 0.5])
            
            p.clearGraphics();
            
            p.imageH = image('CData', img, ...
                'XData', [1 viewport.imageWidth],...
                'YData', [1 viewport.imageHeight], ...
                'CDataMapping', 'scaled', 'Parent', p.axH, 'HitTest', 'off');
            p.rectangleH = viewport.drawBoundaryRectangle('Parent', p.axH, ...
                p.optionalGraphicsParameters{:}, 'HitTest', 'off');
        end
        
        
        function deactivate(p)
            p.clearGraphics();
        end
        
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ishandle(p.imageH)
                delete(p.imageH)
            end
            if ishandle(p.rectangleH)
                delete(p.rectangleH)
            end
        end
    end
    
end

