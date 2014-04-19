classdef NumSpotsTextBox < handle
    
    properties (Access = private)
        textbox
        processorDataHolder
    end
    
    methods
        function p = NumSpotsTextBox(textbox, processorDataHolder)
            p.textbox = textbox;
            p.processorDataHolder = processorDataHolder;
        end
        
        function draw(p)
            numSpots = p.processorDataHolder.processorData.getNumSpots();
            set(p.textbox, 'String', num2str(numSpots))
        end
    end
    
end

