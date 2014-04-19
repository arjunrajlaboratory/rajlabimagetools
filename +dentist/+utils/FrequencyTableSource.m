classdef FrequencyTableSource < handle
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        frequencyTableArray
        channelNames
    end
    
    methods
        function p = FrequencyTableSource(frequencyTableArray)
            p.frequencyTableArray = frequencyTableArray;
            p.channelNames = frequencyTableArray.channelNames;
        end
        
        function spotTable = getSpotFrequencyTable(p, channelName)
           spotTable = p.frequencyTableArray.getByChannelName(channelName);
        end
    end
end

