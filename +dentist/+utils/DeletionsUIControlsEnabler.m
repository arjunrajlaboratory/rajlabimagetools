classdef DeletionsUIControlsEnabler < handle
    %UNTITLED33 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        undoButton
        resetButton
        mouseInterpreter
        displayer
        figH
        axH
    end
    
    methods
        function p = DeletionsUIControlsEnabler(undoButton, resetButton,...
                displayer, mouseInterpreter, figH, axH)
            p.undoButton = undoButton;
            p.resetButton = resetButton;
            p.mouseInterpreter = mouseInterpreter;
            p.displayer = displayer;
            p.axH = axH;
            p.figH = figH;
        end
        
        function enable(p)
            p.displayer.setVisibilityAndDrawIfActive(true);
            p.undoButton.enable();
            p.resetButton.enable();
            p.mouseInterpreter.wireToFigureAndAxes(p.figH, p.axH);
        end
        
        function disable(p)
            p.displayer.setVisibilityAndDrawIfActive(false);
            p.undoButton.disable();
            p.resetButton.disable();
            p.mouseInterpreter.unwire();
        end
        
        function draw(p)
            p.displayer.draw()
        end
    end
    
end

