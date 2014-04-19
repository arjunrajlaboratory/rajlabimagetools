classdef ExtensiblePushButtonGroup < handle
    
    properties (Access = private)
        parentGraphicsHandle
        rectanglePositionCalculator
        numButtons = 0;
        buttonHandles;
    end
    
    methods
        function p = ExtensiblePushButtonGroup(...
                handleToFigOrPanelToFillWithButtons, rectangleArrayPositionCalculator)
            p.rectanglePositionCalculator = rectangleArrayPositionCalculator;
            p.parentGraphicsHandle = handleToFigOrPanelToFillWithButtons;
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
        
        function handleToNewButton = makeNewButton(p, varargin)
            optionalParametersToUIcontrol = varargin;
            p.numButtons = p.numButtons + 1;
            p.adjustPositionsOfExistingButtons()
            newButtonPos = p.getPositionAllocatedToButton(p.numButtons);
            handleToNewButton = uicontrol('Style', 'pushbutton', ...
                'Units', 'normalized', 'Parent', p.parentGraphicsHandle, ...
                'Position', newButtonPos, optionalParametersToUIcontrol{:});
            p.buttonHandles = [p.buttonHandles, handleToNewButton];
        end
    end
    
    methods (Access = private)
        function position = getPositionAllocatedToButton(p, buttonIndex)
            position = p.rectanglePositionCalculator...
                .getPositionOfRectangleInArray(buttonIndex, p.numButtons);
        end
        
        function adjustPositionsOfExistingButtons(p)
            for i = 1:length(p.buttonHandles)
                buttonH = p.buttonHandles(i);
                buttonPos = p.getPositionAllocatedToButton(i);
                set(buttonH, 'Position', buttonPos);
            end
        end
    end
end

