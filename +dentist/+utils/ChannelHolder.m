classdef ChannelHolder < handle
    
    properties (SetAccess = private, GetAccess = private)
        channelName
    end
    
    methods
        function p = ChannelHolder(channelName)
            p.channelName = channelName;
        end
        function setChannelName(p, channelName)
            p.channelName = channelName;
        end
        function channelName = getChannelName(p)
            channelName = p.channelName;
        end
    end
end
