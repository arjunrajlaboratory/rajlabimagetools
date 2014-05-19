classdef ProcessorRegistrarForLegacyimage_object < improc2.interfaces.ProcessorRegistrar
    
    properties (SetAccess = private, GetAccess = private)
        imObHolder
    end
    
    properties (SetAccess = private)
        channelNames
    end
    
    methods
        function p = ProcessorRegistrarForLegacyimage_object(imObHolder)
            p.imObHolder = imObHolder;
        end
        function boolean = hasData(p, channelName, className)
            proc = p.imObHolder.obj.channels.(channelName).processor;
            if isempty(proc)
                boolean = false;
            else
                boolean = isa(proc, className);
            end
        end
        function registerNewData(p, proc, channelName)
            error('improc2:NoLegacySupport', ...
                ['cannot register processors to legacy image_objects.\n',...
                'Simply *set* them with an image object handle'])
        end
    end
end

