classdef MockSequenceRevealingDisplayer < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        timeOfDraw
        timeOfDeactivate
        integerIterator
    end
    
    methods
        function p = MockSequenceRevealingDisplayer(integerIterator)
            p.integerIterator = integerIterator;
        end
        function draw(p)
            p.timeOfDraw = p.integerIterator.next();
        end
        function deactivate(p)
            p.timeOfDeactivate = p.integerIterator.next();
        end
    end
    
end

