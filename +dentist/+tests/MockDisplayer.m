classdef MockDisplayer < dentist.utils.AbstractDisplayer
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        isDrawn = false;
    end
    
    methods
        function draw(p)
            p.isDrawn = true;
        end
        function deactivate(p)
            p.isDrawn = false;
        end
    end
    
end

