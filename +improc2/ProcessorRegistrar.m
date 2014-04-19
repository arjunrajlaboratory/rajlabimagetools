classdef ProcessorRegistrar < improc2.interfaces.ProcessorRegistrar
    %UNTITLED14 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        imObHolder
    end
    
    properties (SetAccess = private, Dependent = true)
        channelNames
    end
    
    methods
        function p = ProcessorRegistrar(imObHolder)
            p.imObHolder = imObHolder;
        end
        
        function channelNames = get.channelNames(p)
            channelNames = p.imObHolder.obj.processors.channelFields;
        end
        
        function registerNewProcessor(p, proc, channelNames)
            channelNames = improc2.utils.validateAndFormatChannelNamesArgument(channelNames);
            if length(channelNames) == 1
                p.registerNewSingleChannelProcessor(proc, channelNames{1});
            else
                p.registerNewMultiChannelProcessor(proc, channelNames);
            end
        end
        
        function boolean = hasProcessorData(p, channelNames, varargin)
            channelNames = improc2.utils.validateAndFormatChannelNamesArgument(channelNames);
            if length(channelNames) == 1
                boolean = p.hasSingleChannelProcessor(channelNames{1}, varargin{:});
            else
                boolean = p.hasMultiChannelProcessor(channelNames, varargin{:});
            end
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p);
            p.displaySingleChannelProcessors()
            p.displayMultiChannelProcessors()
        end
    end
    
    methods (Access = private)
        function registerNewSingleChannelProcessor(p, proc, channelName)
            procmanager = p.imObHolder.obj.processors.channels.(channelName);
            procmanager = procmanager.registerNewProcessor(proc);
            p.imObHolder.obj.processors.channels.(channelName) = procmanager;
        end
        
        function registerNewMultiChannelProcessor(p, proc, channelNames)
            procstack = p.imObHolder.obj.processors;
            procstack = procstack.registerMultiChanProcessor(channelNames, proc);
            p.imObHolder.obj.processors = procstack;
        end
        
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

