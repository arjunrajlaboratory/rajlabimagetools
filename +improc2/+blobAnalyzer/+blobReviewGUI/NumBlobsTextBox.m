classdef NumBlobsTextBox < handle
    
    properties (Access = private)
        textbox
        processorDataHolder
    end
    
    methods
        function p = NumBlobsTextBox(textbox, processorDataHolder)
            p.textbox = textbox;
            p.processorDataHolder = processorDataHolder;
        end
        
        function draw(p)
            [area, centroids, majorAxisLength, minorAxisLength,  eccentricity, extent, perimeter, numBlobs] = p.processorDataHolder.processorData.getBlobProperties();
%             numSpots = p.processorDataHolder.processorData.getNumSpots();
            set(p.textbox, 'String', num2str(numBlobs))
        end
    end
    
end

