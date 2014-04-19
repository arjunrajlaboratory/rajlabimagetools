classdef ProcessorRegistrar < handle
    
    methods (Abstract = true)
        registerNewProcessor(p, proc, channelName)
        boolean = hasProcessorData(p, channelName, className)
    end
    
end

