classdef MultiChannelProcManager < improc2.ChannelSet & improc2.ProcessorStackRunner
    %UNTITLED27 Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties (GetAccess = protected, SetAccess = protected)
        sourceChannelsArray = {};
        % the kth element of this cell array will be itself a cell array
        % such as {'cy','tmr'}, that says which channels contain the
        % single-channel processors whose data is needed to run the kth
        % multichannel processor.
        
        sourcePositionsArray = {};
        % the kth element of this cell array will be a numeric array
        % such as [2,4], that says what position within the single-channel
        % processor queues one should go to contain the
        % single-channel processors whose data is needed to run the kth
        % multichannel processor.
        
        % If sourceChannelsArray{k} = {'cy','tmr'} and
        % sourcePositionsArray{k} = [2,4]
        % then we expect the kth multi channel processor to be called with
        % the second cy-channel processor and the 4th tmr-channel
        % processor.
    end
    
    properties (Dependent = true)
        multiChanProcs;
    end
    
    methods
        function p = MultiChannelProcManager(varargin)
            p = p@improc2.ChannelSet(varargin{:});
            p.description = 'Multi Channel Processor Manager';
        end
        
        function p = registerMultiChanProcessor(p, sourceChannels, proc)
            
            assert(isa(proc,'improc2.procs.ProcessorData'),...
                'improc2:BadArguments', ...
                'Second argument must be an improc2.procs.ProcessorData or subclass')
            assert(length(proc.procDatasIDependOn) > 1, ...
                'Multi Channel Post Processors should depend on at least two processors')
            assert(iscell(sourceChannels) && all(cellfun(@isstr, sourceChannels)), ...
                'improc2:BadArguments', ...
                'First Argument should be a cell array of strings');
            assert(length(sourceChannels) == length(proc.procDatasIDependOn), ...
                'improc2:BadArguments', ...
                ['First Argument must be cell array of %d channelNames\n',...
                'in which to find the source processors of types:\n%s respectively.'],...
                length(proc.procDatasIDependOn), ...
                strjoin(proc.procDatasIDependOn, ' AND '));
            
            newprocPos = length(p.procstack)+1;
            
            p.sourcePositionsArray{ newprocPos } = ...
                p.findNecessarySingleChanProcs(proc, sourceChannels);
            p.sourceChannelsArray{ newprocPos } = sourceChannels;
            p.procstack = p.procstack.registerNewProcessor(proc);
            
        end
        
        % refactor test and get rid of this method.
        function procstack = get.multiChanProcs(p)
            procstack = p.procstack;
        end
        
        function proc = getMultiChanProcBySourceByClass(p, sourceChannels, classname, varargin)
            indexInProcStack = p.findProcStackIndexBySourceByClass(...
                sourceChannels, classname, varargin{:});
            proc = p.procstack.getProcessorByPos(indexInProcStack);
        end
        
        function p = setMultiChanProcBySourceByClass(p, proc, sourceChannels, classname, varargin)
            indexInProcStack = p.findProcStackIndexBySourceByClass(...
                sourceChannels, classname, varargin{:});
            p.procstack = p.procstack.setProcessorByPos(proc, indexInProcStack);
        end
        
        function p = runMultiChanProcBySourceByClass(p, cellArrayOfAdditionalArgs, sourceChannels, classname, varargin)
            indexInProcStack = p.findProcStackIndexBySourceByClass(...
                sourceChannels, classname, varargin{:});
            p = p.runProcAtIndex(indexInProcStack, cellArrayOfAdditionalArgs{:});
        end      
        
        function boolean = hasMultiChanProcMatchingSourceAndClass(p, sourceChannels, classname)
            indices = p.indicesOfMultiChanProcsMatchingSourceAndClass(...
                sourceChannels, classname);
            boolean = ~isempty(indices);
        end
        
        function proc = getMultiChanProcBySourceByPos(p, sourceChannels, varargin)
            indexInProcStack = p.findProcStackIndexBySourceByPos(sourceChannels, varargin{:});
            proc = p.procstack.getProcessorByPos(indexInProcStack);
        end
        
        function p = setMultiChanProcBySourceByPos(p, proc, sourceChannels, varargin)
            indexInProcStack = p.findProcStackIndexBySourceByPos(sourceChannels, varargin{:});
            p.procstack = p.procstack.setProcessorByPos(proc, indexInProcStack);
        end
        
        function p = runMultiChanProcBySourceByPos(p, cellArrayOfAdditionalArgs, sourceChannels, varargin)
            indexInProcStack = p.findProcStackIndexBySourceByPos(sourceChannels, varargin{:});
            p = p.runProcAtIndex(indexInProcStack, cellArrayOfAdditionalArgs{:});
        end

        function p = runAllMultiChanProcs(p)
            p = p.runAllOrUpdateAll('run');
        end
        
        function p = updateAllMultiChanProcs(p)
            p = p.runAllOrUpdateAll('update');
        end
        
        function disp(p)
            disp@improc2.Describeable(p)
            fprintf(1, '\nManaging Single Channel Processors:\n');
            fprintf(1, p.descriptionOfSingleChanProcs);
            fprintf(1, '\nAnd Multi Channel Processors:\n');
            fprintf(1, p.descriptionOfProcStack);
        end
        
        function strout = descriptionOfSingleChanProcs(p)
            channelNamesArray = fields(p.channels);
            strout = '';
            for i = 1:length(channelNamesArray)
                channelName = channelNamesArray{i};
                strout = [strout, ...
                    p.channels.(channelName).processors.descriptionOfArray(channelName)];
            end
        end
        
        function strout = descriptionOfMultiChanProcs(p)
            if length(p.procstack) == 0
                strout = 'none\n';
                return;
            end
            shrinkingSourceChannelsArray = p.sourceChannelsArray;
            uniqueSourceChannelCombinations = {};
            while ~isempty(shrinkingSourceChannelsArray)
                sourceChannels = shrinkingSourceChannelsArray{1};
                uniqueSourceChannelCombinations = ...
                    [uniqueSourceChannelCombinations, {sourceChannels}];
                indicesWithSameSourceChannels = cellfun(...
                    @(x) isequal(x, sourceChannels), shrinkingSourceChannelsArray);
                shrinkingSourceChannelsArray(indicesWithSameSourceChannels) = [];
            end
            strout = '';
            for i = 1:length(uniqueSourceChannelCombinations)
                sourceChannels = uniqueSourceChannelCombinations{i};
                indicesInProcStack = p.indicesOfMultiChanProcsMatchingSource(sourceChannels);
                strout = [strout, sprintf('\t%s\n', strjoin(sourceChannels, ', '))];
                num = 1;
                for j = indicesInProcStack;
                    strout = [strout, sprintf('\t%d) %s\n', num, ...
                        p.procstack.descriptionOfProc(j))];
                    num = num + 1;
                end
            end  
        end
        
        function strout = descriptionOfProc(p,i)
            strout = descriptionOfProc@improc2.ProcessorStackRunner(p,i);
            strout = [strout, ...
                sprintf('\n\t\tUsing: %s.', ...
                strjoin(p.sourceChannelsArray{i}, ', '))];
        end
    end
    
    methods (Access = private)
        function indicesMatchingSource = indicesOfMultiChanProcsMatchingSource(p, sourceChannels)
            indicesMatchingSource = [];
            for i = 1:length(p.procstack)
                if (length(sourceChannels) == length(p.sourceChannelsArray{i})) && ...
                        all(strcmp(sourceChannels, p.sourceChannelsArray{i}))
                    indicesMatchingSource = [indicesMatchingSource, i];
                end
            end
        end
        
        function indicesMatchingBoth = indicesOfMultiChanProcsMatchingSourceAndClass(...
                p, sourceChannels, classname)
            indicesMatchingSource = p.indicesOfMultiChanProcsMatchingSource(sourceChannels);
            indicesMatchingBoth = [];
            for i = indicesMatchingSource
                if isa(p.procstack.getProcessorByPos(i), classname)
                    indicesMatchingBoth = [indicesMatchingBoth, i];
                end
            end
        end
        
        function indexInProcStack = findProcStackIndexBySourceByPos(p, sourceChannels, index)
            if nargin < 3
                index = 1;
            end
            indices = p.indicesOfMultiChanProcsMatchingSource(sourceChannels);
            indexInProcStack = indices(index); %GPN: I thoroughly apologize for this.
        end
        
        function indexInProcStack = findProcStackIndexBySourceByClass(p, ...
                sourceChannels, classname, lastorfirst)
            if nargin < 4
                lastorfirst = 'first';
            end
            indices = p.indicesOfMultiChanProcsMatchingSourceAndClass(...
                sourceChannels, classname);
            assert(~isempty(indices), 'improc2:ProcNotFound', ...
                'No existing processor of type %s found using source Channels %s', ...
                classname, strjoin(sourceChannels, ', '))
            switch lastorfirst
                case 'first'
                    indexInProcStack = indices(1);
                case 'last'
                    indexInProcStack = indices(end);
            end
        end
    end
    
    methods (Access = protected)
        
        % override abstract method
        function procscell = getProcsNecessaryToRun(p, index)
            sourceChannels = p.sourceChannelsArray{index};
            procindices = p.sourcePositionsArray{index};
            procscell = cell(size(procindices));
            for i = 1:length(procindices)
                procscell{i} = p.channels.(sourceChannels{i})...
                    .processors.getProcessorByPos(procindices(i));
            end
        end
        
        function indices = findNecessarySingleChanProcs(p, proc, sourceChannels)
            indices = zeros([1 length(sourceChannels)]);
            for i = 1:length(sourceChannels)
                try
                    indices(i) = p.channels.(sourceChannels{i}).processors.indexFromClassName(...
                        proc.procDatasIDependOn{i},'last');
                catch err
                    if strcmp(err.identifier, 'improc2:ProcNotFound')
                        error('improc2:DependencyNotFound', ...
                            ['Could not find a %s-channel %s processor \n'...
                            'necessary to run this multi-channel post-processor.'], ...
                            sourceChannels{i}, proc.procDatasIDependOn{i});
                    else
                        throw(err)
                    end
                end
            end
        end
        
        % Override
        function p = actionOnDataChangeAtChan(p, channelName, dataHasChangedArray)
            for i = 1:length(p.procstack)
                sourceChans = p.sourceChannelsArray{i};
                sourcePositions = p.sourcePositionsArray{i};
                
                for dependencyNum = 1:length(sourceChans)
                    if strcmp(sourceChans{dependencyNum}, channelName)
                        if dataHasChangedArray(sourcePositions(dependencyNum))
                            proc = p.procstack.getProcessorByPos(i);
                            proc = proc.setNeedsUpdateTrue;
                            p.procstack = ...
                                p.procstack.setProcessorByPos(proc,i);
                        end
                    end
                end
            end
        end
    end
end


