classdef MockThresholdHolder < handle
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        thresholdsStruct
        channelNames
    end
    
    methods
        function p = MockThresholdHolder(thresholdsStruct)
            p.thresholdsStruct = thresholdsStruct;
            p.channelNames = fields(thresholdsStruct);
        end
        
        function value = getThreshold(p, channelName)
           value = p.thresholdsStruct.(char(channelName)); 
        end
        
        function setThreshold(p, value, channelName)
            p.thresholdsStruct.(char(channelName)) = value;
        end
    end
end

