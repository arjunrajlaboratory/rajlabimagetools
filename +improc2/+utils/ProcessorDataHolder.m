classdef ProcessorDataHolder < handle
    
    properties (Access = private)
        objectHandle
        channelHolder
        processorFetchingParams
        actionsAfterSetProcessor
    end
    
    properties (Dependent = true)
        processorData
    end
    
    methods
        function p = ProcessorDataHolder(...
                objectHandle, channelHandle, varargin)
            p.channelHolder = channelHandle;
            p.objectHandle = objectHandle;
            
            p.processorFetchingParams = varargin;
            p.actionsAfterSetProcessor = improc2.utils.DependencyRunner();
        end
        
        function addActionAfterSetProcessor(p, handleToObject, funcToRunOnIt)
            p.actionsAfterSetProcessor.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        function channelName = getChannelName(p)
            % This function is used to get the channel name of the current
            % channel in Threshold GUI. Useful for recalculating zMerges
            % after excluding slices.
            channelName = p.channelHolder.getChannelName();
        end
        
        function procData = get.processorData(p)
            procData = p.objectHandle.getData(...
                p.channelHolder.getChannelName(), p.processorFetchingParams{:});
        end
        
        function set.processorData(p, procData)
            p.objectHandle.setData(...
                procData, p.channelHolder.getChannelName(), p.processorFetchingParams{:});
            p.actionsAfterSetProcessor.runDependencies();
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
end

