classdef ImageObjectHandle < improc2.interfaces.ImageObjectHandle
    
    properties (SetAccess = private, GetAccess = private)
        imObHolder
    end
    
    properties (SetAccess = private, Dependent = true)
        channelNames
    end
    
    methods
        function p = ImageObjectHandle(imObHolder)
            p.imObHolder = imObHolder;
        end
        
        function channelNames = get.channelNames(p)
            channelNames = p.imObHolder.obj.processors.channelFields;
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
        
        function boolean = hasProcessorData(p, channelNames, varargin)
            channelNames = improc2.utils.validateAndFormatChannelNamesArgument(channelNames);
            if length(channelNames) == 1
                boolean = p.hasSingleChannelProcessor(channelNames{1}, varargin{:});
            else
                boolean = p.hasMultiChannelProcessor(channelNames, varargin{:});
            end
        end
        
        function procData = getProcessorData(p, channelNames, varargin)
            channelNames = improc2.utils.validateAndFormatChannelNamesArgument(channelNames);
            if length(channelNames) == 1
                procData = p.getSingleChannelProcessor(channelNames{1}, varargin{:});
            else
                procData = p.getMultiChannelProcessor(channelNames, varargin{:});
            end
            if procData.needsUpdate || ~procData.isProcessed
                warning('improc2:NeedsRunOrUpdate', ...
                    'This processor data may be out of date. Run or update it')
            end
        end
        
        function setProcessorData(p, procData, channelNames, varargin)
            channelNames = improc2.utils.validateAndFormatChannelNamesArgument(channelNames);
            if length(channelNames) == 1
                p.setSingleChannelProcessor(procData, channelNames{1}, varargin{:});
            else
                p.setMultiChannelProcessor(procData, channelNames, varargin{:});
            end
        end
        
        function filename = getImageFileName(p, channelName)
            filename = p.imObHolder.obj.processors.channels.(channelName).filename;
        end
        
        function dirPath = getImageDirPath(p)
            dirPath = p.imObHolder.obj.dirPath;
        end
        
        function runProcessor(p, extraProcessorArgsCellArray, channelNames, varargin)
            channelNames = improc2.utils.validateAndFormatChannelNamesArgument(channelNames);
            if length(channelNames) == 1
                p.runSingleChannelProcessor(extraProcessorArgsCellArray, channelNames{1}, varargin{:});
            else
                p.runMultiChannelProcessor(extraProcessorArgsCellArray, channelNames, varargin{:});
            end
        end
        
        function runAllProcessors(p)
            processors = p.imObHolder.obj.processors;
            processors = runAllSingleChanProcsUsingImgObjHandle(processors, p);
            processors = runAllMultiChanProcs(processors);
            p.imObHolder.obj.processors = processors;
        end
        
        function updateAllProcessors(p)
            processors = p.imObHolder.obj.processors;
            processors = updateAllSingleChanProcsUsingImgObjHandle(processors, p);
            processors = updateAllMultiChanProcs(processors);
            p.imObHolder.obj.processors = processors;
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p);
            p.displaySingleChannelProcessors()
            p.displayMultiChannelProcessors()
        end
        
    end
    
    methods (Access = private)
        
        function boolean = hasSingleChannelProcessor(p, channelName, varargin)
            procstack = p.imObHolder.obj.processors.channels.(channelName).processors;
            if ~isempty(varargin)
                boolean = procstack.hasProcessorData(varargin{:});
            else
                boolean = length(procstack) > 0;
            end
        end
        
        function boolean = hasMultiChannelProcessor(p, channelNames, varargin)
            procstack = p.imObHolder.obj.processors;
            boolean = procstack.hasMultiChanProcMatchingSourceAndClass(...
                channelNames, varargin{:});
        end
        
        function runSingleChannelProcessor(p, extraProcessorArgsCellArray, channelName, varargin)
            procstack = p.imObHolder.obj.processors.channels.(channelName).processors;
            if ~isempty(varargin)
                procIndex = procstack.indexFromClassName(varargin{:});
            else
                procIndex = 1;
            end
            p.imObHolder.obj.processors.channels.(channelName) = ...
                p.imObHolder.obj.processors.channels.(channelName).runProcAtIndex(...
                procIndex, extraProcessorArgsCellArray{:});
        end
        
        function proc = getSingleChannelProcessor(p, channelName, varargin)
            procstack = p.imObHolder.obj.processors.channels.(channelName).processors;
            if ~isempty(varargin)
                procIndex = procstack.indexFromClassName(varargin{:});
            else
                procIndex = 1;
            end
            proc = procstack.getProcessorByPos(procIndex);
        end
        
        function setSingleChannelProcessor(p, proc, channelName, varargin)
            procstack = p.imObHolder.obj.processors.channels.(channelName).processors;
            if ~isempty(varargin)
                procIndex = procstack.indexFromClassName(varargin{:});
            else
                procIndex = 1;
            end
            procstack = procstack.setProcessorByPos(proc, procIndex);
            p.imObHolder.obj.processors.channels.(channelName).processors = procstack;
        end
        
        
        function proc = getMultiChannelProcessor(p, channelNames, varargin)
            procstack = p.imObHolder.obj.processors;
            if ~isempty(varargin)
                proc = procstack.getMultiChanProcBySourceByClass(...
                    channelNames, varargin{:});
            else
                proc = procstack.getMultiChanProcBySourceByPos(...
                    channelNames, 1);
            end
        end
        
        function setMultiChannelProcessor(p, proc, channelNames, varargin)
            procstack = p.imObHolder.obj.processors;
            if ~isempty(varargin)
                procstack = procstack.setMultiChanProcBySourceByClass(...
                    proc, channelNames, varargin{:});
            else
                procstack = procstack.setMultiChanProcBySourceByPos(...
                    proc, channelNames, 1);
            end
            p.imObHolder.obj.processors = procstack;
        end
        
        function runMultiChannelProcessor(p, extraProcessorArgsCellArray, channelNames, varargin)
            procstack = p.imObHolder.obj.processors;
            if ~isempty(varargin)
                procstack = procstack.runMultiChanProcBySourceByClass(...
                    extraProcessorArgsCellArray, channelNames, varargin{:});
            else
                procstack = procstack.runMultiChanProcBySourceByPos(...
                    extraProcessorArgsCellArray, channelNames, 1);
            end
            p.imObHolder.obj.processors = procstack;
        end
        
        function displaySingleChannelProcessors(p)
            fprintf('* Single channel processors:\n')
            fprintf(p.imObHolder.obj.processors.descriptionOfSingleChanProcs)
            fprintf('\n');
        end
        function displayMultiChannelProcessors(p)
            fprintf('* Multi channel processors:\n')
            fprintf(p.imObHolder.obj.processors.descriptionOfMultiChanProcs)
        end
    end
end
