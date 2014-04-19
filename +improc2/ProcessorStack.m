classdef ProcessorStack < improc2.Describeable
    %UNTITLED34 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private, SetAccess = private)
        processorArray = {};
    end
    
    methods
        function p = ProcessorStack()
            p.description = 'Processor Stack';
        end
        
        function p = registerNewProcessor(p, proc)
            if ~isa(proc, 'improc2.procs.ProcessorData')
                error('improc2:BadArguments','input must be an improc2.procs.ProcessorData');
            end
            p.processorArray = [p.processorArray, {proc}];
        end
        
        %%   **** Override of MATLAB length operator ****
        
        function len = length(p)
            len = length(p.processorArray);
        end
        
        %%  **** get and set processor by position in queue ****
        
        function proc = getProcessorByPos(p, index)
            proc = p.processorArray{index};
        end
        
        function p = setProcessorByPos(p, proc, index)
            
            if ~strcmp( class(p.processorArray{index}), class(proc) )
                error('improc2:ProcessorReplaceConflict', ...
                    'Replacement must be a processor of same class')
            end
            p.processorArray{index} = proc;
        end
        
        %%   **** find queue position for processor matching a ClassName ****
        
        function index = indexFromClassName(p, classname, varargin)
            
            procIndices = p.findProcessorIndices(classname, varargin{:});
            
            assert(~isempty(procIndices), ...
                'improc2:ProcNotFound', ['No processor of type ', classname,...
                ' found in queue\nwithin requested position range.'])
            
            index = procIndices(1);
        end
        
        function boolean = hasProcessorData(p, varargin)
            procIndices = p.findProcessorIndices(varargin{:});
            boolean = ~isempty(procIndices);
        end
        
        %%   **** Overrides of MATLAB indexing operator ****
        
        function out = subsref(p,s)
            switch s(1).type
                case '()'
                    % With this, a call like p(k) will return the kth
                    % processor.
                    out = p.getProcessorByPos(s(1).subs{1});
                    if length(s)>1
                        out = subsref(out, s(2:end));
                    end
                otherwise
                    out = builtin('subsref',p,s);
            end
        end
        
        function p = subsasgn(p,s,in)
            switch s(1).type
                case '()'
                    % With this, a call like p(k) = proc; or
                    % p(k).someproperty = newvalue; will update the
                    % kth processor in the processorManager appropriately.
                    index = s(1).subs{1};
                    if length(s) > 1
                        procin = p.getProcessorByPos(index);
                        procin = subsasgn(procin, s(2:end), in);
                    else
                        procin = in;
                    end
                    p = p.setProcessorByPos(procin, index);
                otherwise
                    p = builtin('subsasgn',p,s,in);
            end
        end
        
        %%  ****    Override of Describeable disp ****
        
        function disp(p)
            disp@improc2.Describeable(p)
            fprintf(1,'\nContaining:\n');
            fprintf(1,p.descriptionOfArray);
        end
        
        function strout = descriptionOfArray(p, prefix)
            if nargin < 2
                prefix = '';
            end
            strout = prefix;
            if length(p) < 1
                strout = [strout, '\t(empty)\n'];
                return;
            end
            for i = 1:length(p)
                strout = [strout, ...
                    sprintf('\t%d) %s\n', i, p.descriptionOfProc(i))];
            end
        end
        
        function strout = descriptionOfProc(p,index)
            proc = p.getProcessorByPos(index);
            strout = class(proc);
            if ~proc.isProcessed;
                strout = [strout, '\t(not processed yet!)'];
            end
            if proc.needsUpdate
                strout = [strout, '\t(needs update!)'];
            end
        end
    end
    
    methods (Access = private)
        function indices = findProcessorIndices(p, classname, startingFromlastorfirst, ...
                minindex, maxindex)
            if nargin < 3; startingFromlastorfirst = 'first'; end
            if nargin < 4; minindex = 1; end
            if nargin < 5; maxindex = length(p); end
            
            indicesToCheck = minindex : maxindex;
            if strcmp(startingFromlastorfirst,'last');
                indicesToCheck = fliplr(indicesToCheck);
            elseif ~strcmp(startingFromlastorfirst,'first')
                error('Third input must be the string first or last');
            end
            
            indices = [];
            for i = indicesToCheck
                if isa(p.getProcessorByPos(i), classname)
                    indices = [indices, i];
                end
            end
        end
    end
    
end

