classdef SpotsPerSliceDisplayer < handle
    
    properties (Access = private)
        axH
        processorDataHolder
        rectanglesIncludedH
        rectanglesExcludedH
    end
    
    methods
        function p = SpotsPerSliceDisplayer(axH, processorDataHolder)
            p.axH = axH;
            p.processorDataHolder = processorDataHolder;
        end
        
        function draw(p)
            p.clearGraphics()
            procData = p.processorDataHolder.processorData;
            [hIncluded, hExcluded, xCoords, yCoords] = ...
                improc2.utils.plotSpotsVsSliceHistogram(procData, 'Parent', p.axH);
            set(p.axH, 'YLim', [0, max([yCoords.included(:); yCoords.excluded(:)])])
            xlimMax = max(5, 1.1 *max(xCoords.included(:)));
            set(p.axH, 'XLim', [0, xlimMax])
            p.rectanglesIncludedH = hIncluded;
            p.rectanglesExcludedH = hExcluded;
        end
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ~isempty(p.rectanglesIncludedH) && ishandle(p.rectanglesIncludedH)
                delete(p.rectanglesIncludedH)
            end
            if ~isempty(p.rectanglesExcludedH) && ishandle(p.rectanglesExcludedH)
                delete(p.rectanglesExcludedH)
            end
        end
    end
    
end

