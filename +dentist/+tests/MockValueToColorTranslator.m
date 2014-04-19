classdef MockValueToColorTranslator < handle
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private);
        storedFunc
        storedCmap
    end
    
    methods
        function p = MockValueToColorTranslator(func, cmap)
            p.storedFunc = func;
            p.storedCmap = cmap;
        end
        
        function setScalingFunction(p, func)
            p.storedFunc = func;
        end
        
        function setColorMap(p, cmap)
            p.storedCmap = cmap;
        end
    end
    
end

