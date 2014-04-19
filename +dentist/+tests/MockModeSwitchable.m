classdef MockModeSwitchable < handle
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mode = [];
    end
    
    methods
        function setMode(p, mode)
            p.mode = mode;
        end
    end
end

