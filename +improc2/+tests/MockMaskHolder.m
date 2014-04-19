classdef MockMaskHolder < handle
    %UNTITLED12 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        mask
    end
    
    methods
        function p = MockMaskHolder(mask)
            p.mask = mask;
        end
        function mask = getMask(p)
            mask = p.mask;
        end
    end
    
end

