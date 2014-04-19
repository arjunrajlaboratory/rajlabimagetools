classdef DisplayerSequence < dentist.utils.AbstractDisplayer
    %UNTITLED21 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        cellArrayOfDisplayers
    end
    
    methods
        function p = DisplayerSequence(varargin)
            p.cellArrayOfDisplayers = varargin;
        end
        
        function draw(p)
            for i = 1:length(p.cellArrayOfDisplayers)
                p.cellArrayOfDisplayers{i}.draw();
            end
        end
        
        function deactivate(p)
            for i = 1:length(p.cellArrayOfDisplayers)
                p.cellArrayOfDisplayers{i}.deactivate();
            end
        end 
    end
end

