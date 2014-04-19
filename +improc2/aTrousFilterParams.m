classdef aTrousFilterParams < improc2.ParamList
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sigma = 0.5;     %width of the gaussian to use
        numLevels = 3;   %number of detail levels to use
    end
    
    methods
        
        function p = aTrousFilterParams(param_struct) 
            if nargin ~= 0
                p = p.replaceParams(param_struct);
            end
        end
        
    end
    
end

