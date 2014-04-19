classdef MockEnableable < handle
    %UNTITLED35 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        enabled = false;
    end
    
    methods
        function enable(p)
            p.enabled = true;
        end
        function disable(p)
            p.enabled = false;
        end
    end
    
end

