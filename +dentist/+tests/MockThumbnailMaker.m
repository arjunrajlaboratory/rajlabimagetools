classdef MockThumbnailMaker < handle
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        prioritized = 'high';
        timesMade = 0;
        thumbnailWidth
        thumbnailHeight
        pixelExpansionSize
    end
    
    methods
        function prioritizeLowExpressers(p)
            p.prioritized = 'low';
        end
        function prioritizeHighExpressers(p)
            p.prioritized = 'high';
        end
        function makeAndStore(p)
            p.timesMade = p.timesMade + 1;
        end
        function setThumbnailWidthAndHeight(p, width, height)
            p.thumbnailWidth = width;
            p.thumbnailHeight = height;
        end
        function setPixelExpansionSize(p, expandedPixelSideLengthInImage)
            p.pixelExpansionSize = expandedPixelSideLengthInImage;
        end
    end
    
end

