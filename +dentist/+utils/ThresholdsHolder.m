classdef ThresholdsHolder < handle
    
    properties
        thresholds
        actionsOnUpdate
    end
    
    methods
        function p = ThresholdsHolder(thresholds)
            p.thresholds = thresholds;
            p.actionsOnUpdate = improc2.utils.DependencyRunner();
        end
        
        function setThreshold(p, value, channelName)
            p.thresholds = p.thresholds.setByChannelName(value, channelName);
            p.actionsOnUpdate.runDependencies();
        end
        
        function value = getThreshold(p, channelName)
            value = p.thresholds.getByChannelName(channelName);
        end
        
        function addActionOnUpdate(p, handleToObject, funcToRunOnIt)
            p.actionsOnUpdate.registerDependency(handleToObject, funcToRunOnIt);
        end
    end
    
end

