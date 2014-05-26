classdef HandleToLegacyimage_object < improc2.interfaces.ImageObjectHandle
    
    properties (SetAccess = private, GetAccess = private)
        imObHolder
    end
    
    properties (SetAccess = private)
        channelNames
    end
    
    methods
        function p = HandleToLegacyimage_object(imObHolder)
            p.imObHolder = imObHolder;
        end
        function metadata = getMetaData(p)
            metadata = p.imObHolder.obj.metadata;
        end
        function setMetaData(p, metadata)
            p.imObHolder.obj.metadata = metadata;
        end
        function objMask = getCroppedMask(p)
            objMask = p.imObHolder.obj.object_mask.mask;
        end
        function imFileMask = getMask(p)
            imFileMask = p.imObHolder.obj.object_mask.imfilemask;
        end
        function bbox = getBoundingBox(p)
            bbox = p.imObHolder.obj.object_mask.boundingbox;
        end
        function channelNames = get.channelNames(p)
            channelNames = fields(p.imObHolder.obj.channels);
        end
        function boolean = hasData(p, channelName, className)
            proc = p.imObHolder.obj.channels.(channelName).processor;
            if isempty(proc)
                boolean = false;
            else
                boolean = isa(proc, className);
            end
        end
        function proc = getData(p, channelName, varargin)
            proc = p.imObHolder.obj.channels.(channelName).processor;
        end
        function setData(p, proc, channelName, varargin)
            p.imObHolder.obj.channels.(channelName).processor = proc;
        end
        function filename = getImageFileName(p, channelName)
            filename = p.imObHolder.obj.channels.(channelName).filename;
        end
        function dirPath = getImageDirPath(p)
            dirPath = p.imObHolder.obj.filenames.path;
        end
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p);
            fprintf('* Channels:\n')
            fprintf('\t%s\n', improc2.utils.stringJoin(p.channelNames(:)', ' '))
        end
    end
end

