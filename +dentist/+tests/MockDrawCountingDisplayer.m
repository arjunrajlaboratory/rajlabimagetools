classdef MockDrawCountingDisplayer < dentist.utils.AbstractDisplayer
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        timesDrawn = 0;
        printToConsole = true;
    end
    
    methods
        function p = MockDrawCountingDisplayer(printToConsole)
            if nargin == 1
                p.printToConsole = printToConsole;
            end
        end
        function draw(p)
            p.timesDrawn = p.timesDrawn + 1;
            if p.printToConsole
                fprintf('Times drawn = %d\n', p.timesDrawn)
            end
        end
        function deactivate(p)
            p.timesDrawn = 0;
            if p.printToConsole
                fprintf('Deactivated, reset to %d\n', p.timesDrawn)
            end
        end
    end
    
end


