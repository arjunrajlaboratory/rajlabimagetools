classdef MockChannelGrabbingDisplayer < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        channelHolder
        channelGrabbedOnDraw
        timesDeactivated = 0;
        timesDrawn = 0;
        identifier = 'emptyID';
    end
    
    methods
        function p = MockChannelGrabbingDisplayer(channelHolder, identifier)
            p.channelHolder = channelHolder;
            p.identifier = identifier;
        end
        function draw(p)
            p.channelGrabbedOnDraw = p.channelHolder.getChannelName();
            p.timesDrawn = p.timesDrawn + 1;
            fprintf('Displayer %s draw using channel %s\n', p.identifier, ...
                p.channelGrabbedOnDraw)
        end
        function deactivate(p)
            p.timesDeactivated = p.timesDeactivated + 1;
        end
    end
    
end

