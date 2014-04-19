classdef ChannelsWithProcessorNavigator < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        imageObjectController
        processorClassName
    end
    
    properties (SetAccess = private)
        channelNames
        currentChannelName
    end
    
    properties (Dependent = true)
        processor
    end
    
    methods
        function p = ChannelsWithProcessorNavigator(imageObjectController, ...
                processorClassName)
            p.imageObjectController = imageObjectController;
            p.processorClassName = processorClassName;
            p.findChannelsWithProcessorsOfRequiredType();
            p.currentChannelName = p.channelNames{1};
        end
        
        function goToChannel(p, channelName)
            channelName = char(channelName);
            assert(ismember(channelName, p.channelNames), ...
                'improc2:ChannelNotFound', ...
                'No %s channel in ChannelNavigator', channelName)
            p.currentChannelName = channelName;
        end
        
        function proc = get.processor(p)
            proc = p.imageObjectController.getProcessorData(...
                p.currentChannelName, p.processorClassName);
        end
        
        function set.processor(p, proc)
            p.imageObjectController.setProcessorData(proc, ...
                p.currentChannelName, p.processorClassName);
        end
    end
    
    methods (Access = private)
        function findChannelsWithProcessorsOfRequiredType(p)
            channelCandidates = p.imageObjectController.channelNames;
            p.channelNames = {};
            for i = 1:length(channelCandidates)
                channelName = channelCandidates{i};
                if p.imageObjectController.hasProcessorData(channelName, ...
                        p.processorClassName)
                    p.channelNames = [p.channelNames {channelName}];
                end
            end
            assert(~isempty(p.channelNames), 'improc2:ProcessorNotFound', ...
                ['No channels with requested %s processor '], p.processorClassName)
        end
    end
end

