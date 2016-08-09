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
        function oHandle = getObjectHandle(p)
            oHandle = p.objectHandle;
        end
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
            channelName = strcat(p.channelHolder.getChannelName(),':Spots');
        end
        
        function procData = get.processorData(p)
            if isa(p.processorFetchingParams{1}, 'char')
                procData = p.objectHandle.getData(...
                    p.channelHolder.getChannelName(), p.processorFetchingParams{:});
            elseif isa(p.processorFetchingParams{1}, 'containers.Map')
                procData = p.objectHandle.getData(...
                    p.channelHolder.getChannelName(), p.processorFetchingParams{1}(p.channelHolder.getChannelName()));
            end
        end
        
        function set.processorData(p, procData)
            if isa(p.processorFetchingParams{1}, 'char')
                p.objectHandle.setData(...
                    procData, p.channelHolder.getChannelName(), p.processorFetchingParams{:});
                p.actionsAfterSetProcessor.runDependencies();
            elseif isa(p.processorFetchingParams{1}, 'containers.Map')
                p.objectHandle.setData(...
                    procData, p.channelHolder.getChannelName(), p.processorFetchingParams{1}(p.channelHolder.getChannelName()));
                p.actionsAfterSetProcessor.runDependencies();
            end
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
end

