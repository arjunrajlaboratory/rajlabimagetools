classdef ThumbnailsProvider < handle
    %UNTITLED12 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        thumbnailMakers
    end
    properties (Dependent = true)
        channelNames
    end
    
    methods
        function p = ThumbnailsProvider(thumbnailMakers)
            p.thumbnailMakers = thumbnailMakers;
        end
        function thumbnail = getByChannelName(p, channelName)
            thumbnailMaker = p.thumbnailMakers.getByChannelName(channelName);
            thumbnail = thumbnailMaker.getRGBImage();
        end
        function channelNames = get.channelNames(p)
            channelNames = p.thumbnailMakers.channelNames;
        end
    end
    
end

