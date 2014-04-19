classdef (Abstract) ProcessorStackRunner < improc2.Describeable
    %UNTITLED37 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess =  protected, SetAccess = protected)
        procstack = improc2.ProcessorStack;
    end
    
    
    
    methods (Access = protected, Abstract = true)
        procscell = getProcsNecessaryToRun(p, index);
    end
    
    methods
        
        function p = ProcessorStackRunner(procstack)
            if nargin > 0
                assert(isa(procstack, 'improc2.ProcessorStack'),...
                    'Input must be an improc2.ProcessorStack')
                p.procstack = procstack;
            else
                p.procstack = improc2.ProcessorStack();
            end
        end
        
        %% High level method for running a processor in a stack.
        
        function p = runProcAtIndex(p, index, varargin)
            % Collects all processors that the ith processor depends on,
            % and sends them to the ith processor's run command followed by
            % any more given parameters. After that, assume that the
            % processor does not need an update any more.
            inputprocs = p.getProcsNecessaryToRun(index);
            varargin = [inputprocs, varargin];
            proc = p.procstack.getProcessorByPos(index);
            proc = proc.run(varargin{:});
            
            proc = proc.setNeedsUpdateFalse;

            p.procstack = p.procstack.setProcessorByPos(proc, index);
        end

        %% *** Override of MATLAB length ***
        
        function len = length(p)
            len = length(p.procstack);
        end
        
        %% *** Override of Describeable disp ***
        
        function disp(p)
            disp@improc2.Describeable(p)
            fprintf(1,'\nManaging Processors:\n');
            fprintf(1,p.descriptionOfProcStack);
        end
        
        function strout = descriptionOfProcStack(p)
            strout = '';
            if length(p) < 1
                strout = '(empty) no Processors registered yet.\n';
                return;
            end
            for i = 1:length(p)
                strout = [strout, ...
                    sprintf('\t%d) %s\n', i, p.descriptionOfProc(i))];
            end
        end
        
        function strout = descriptionOfProc(p,i)
            strout = p.procstack.descriptionOfProc(i);
        end
        
    end
    
    methods (Access = protected)
%%        
        function p = runAllOrUpdateAll(p, runOrUpdate, varargin)
            switch runOrUpdate
                case 'run'
                    updateOnly = false;
                case 'update'
                    updateOnly = true;
                otherwise
                    error('Second argument must be string "run" or "update"');
            end
            for i = 1:length(p)
                if updateOnly
                    proc = p.procstack.getProcessorByPos(i);
                    if proc.isProcessed && ~proc.needsUpdate
                        continue;
                    end
                end
                p = p.runProcAtIndex(i, varargin{:});
            end
        end
    end
    
end

