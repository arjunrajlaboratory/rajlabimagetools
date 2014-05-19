classdef ProcessorRegistrar < handle
    
    methods (Abstract = true)
        registerNewData(p, proc, channelName)
        boolean = hasData(p, channelName, className)
    end
    
end

