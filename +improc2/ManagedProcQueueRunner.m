classdef ManagedProcQueueRunner < improc2.ProcessorStackRunner
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Dependent = true)
        processors
    end
    
    methods
        function p = ManagedProcQueueRunner(procstack)
            if nargin > 0
                assert(isa(procstack, 'improc2.ManagedProcessorQueue'),...
                    'Input must be an improc2.ManagedProcessorQueue')
                p.procstack = procstack;
            else
                p.procstack = improc2.ManagedProcessorQueue();
            end
        end
        
        function p = registerNewProcessor(p, proc)
            p.procstack = p.procstack.registerNewProcessor(proc);
        end
        
        function procs = get.processors(p)
            procs = p.procstack;
        end
        
        function p = set.processors(p, procs)
            p.procstack = procs;
        end
        
    end
    
    methods (Access = protected)
        function procscell = getProcsNecessaryToRun(p, index)
            procscell = p.procstack.getProcsNecessaryToRun(index);
        end
    end
end

