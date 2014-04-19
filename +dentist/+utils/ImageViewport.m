classdef ImageViewport
    
    properties (SetAccess = private)
        ulCornerXPosition
        ulCornerYPosition
        imageWidth
        imageHeight
        width
        height
    end
    
    properties (Dependent)
        centerXPosition
        centerYPosition
    end
    
    methods
        function p = ImageViewport(imageWidth, imageHeight)
            p.imageWidth = imageWidth;
            p.imageHeight = imageHeight;
            p.ulCornerXPosition = 1;
            p.ulCornerYPosition = 1;
            p.width = p.imageWidth;
            p.height = p.imageHeight;
        end
        
        % No tests written for this
        function p = setToMatchViewport(p, viewportToMatch)
            xScaleFactor = p.imageWidth / viewportToMatch.imageWidth;
            yScaleFactor = p.imageHeight / viewportToMatch.imageHeight;
            
            p = p.setWidth(viewportToMatch.width * xScaleFactor);
            p = p.setHeight(viewportToMatch.height * yScaleFactor);
            
            p = p.tryToPlaceULCornerAtXPosition(...
                viewportToMatch.ulCornerXPosition * xScaleFactor);
            p = p.tryToPlaceULCornerAtYPosition(...
                viewportToMatch.ulCornerYPosition * yScaleFactor);
        end
        
        % No tests written for this
        function p = centerAndScaleSize(p, centerXPosition, centerYPosition, scaleFactor)
            if nargin == 4
                p = p.scaleSize(scaleFactor);
            end
            p = p.tryToCenterAtXPosition(centerXPosition);
            p = p.tryToCenterAtYPosition(centerYPosition);
        end
        
        % No tests written for this
        function p = setFromRectanglePosition(p, x0, y0, width, height)
            p = p.setWidth(width);
            p = p.setHeight(height);
            p = p.tryToPlaceULCornerAtXPosition(x0 + 0.5);
            p = p.tryToPlaceULCornerAtYPosition(y0 + 0.5);
        end
        
        % No tests written
        function p = tryToPlaceULCornerAtXPosition(p, x)
            p.ulCornerXPosition = max(min(round(x), p.imageWidth - p.width + 1), 1);
        end
        
        % No tests written
        function p = tryToPlaceULCornerAtYPosition(p, y)
            p.ulCornerYPosition = max(min(round(y), p.imageHeight - p.height + 1), 1);
        end
        
        function img = getCroppedImage(p, fullImg)
            img = fullImg(p.ulCornerYPosition : p.ulCornerYPosition + p.height - 1, ...
                p.ulCornerXPosition : p.ulCornerXPosition + p.width - 1, :);
        end
        
        
        function p = tryToCenterAtXPosition(p, x)
            p.ulCornerXPosition = tryToCenterInterval(x, ...
                p.width, p.imageWidth);
        end
        
        function p = tryToCenterAtYPosition(p, y)
            p.ulCornerYPosition = tryToCenterInterval(y, ...
                p.height, p.imageHeight);
        end
        
        function x = get.centerXPosition(p)
            x = p.ulCornerXPosition + (p.width - 1) / 2;
        end
        
        function y = get.centerYPosition(p)
            y = p.ulCornerYPosition + (p.height - 1) / 2;
        end
        
        function p = scaleSize(p, scaleFactor)
            p = p.setWidth(p.width * scaleFactor);
            p = p.setHeight(p.height * scaleFactor);
        end
        
        function p = setWidth(p, width)
            oldXcenter = p.centerXPosition;
            p.width = max(min(round(width), p.imageWidth), 1);
            p = p.tryToCenterAtXPosition(oldXcenter);
        end
        
        function p = setHeight(p, height)
            oldYcenter = p.centerYPosition;
            p.height = max(min(round(height), p.imageHeight), 1);
            p = p.tryToCenterAtYPosition(oldYcenter);
        end
        
        function TF = contains(p, x, y)
            TF = (p.ulCornerXPosition <= x) & ...
                (x <= p.ulCornerXPosition + p.width - 1) & ...
                (p.ulCornerYPosition <= y) & ...
                (y <= p.ulCornerYPosition + p.height - 1);
        end
        
        function rectH = drawBoundaryRectangle(p, varargin)
            rectH = rectangle('Position', [p.ulCornerXPosition-0.5, ...
                p.ulCornerYPosition-0.5, p.width, p.height], ...
                varargin{:});
        end
        
        
    end
end


function intervalLeftEdge = tryToCenterInterval(requestedIntervalCenter, ...
        roiLength, totalLength)
    requestedLeftEdge = requestedIntervalCenter - (roiLength - 1)/2;
    requestedRightEdge = requestedIntervalCenter + (roiLength - 1)/2;
    if round(requestedRightEdge) <= totalLength
        intervalLeftEdge = max(1, round(requestedLeftEdge));
    else
        intervalLeftEdge = totalLength - (roiLength-1);
    end
end







