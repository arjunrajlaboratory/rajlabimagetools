classdef DataChangeTrackedProcStack < improc2.ProcessorStack & ...
        improc2.LoadSafeDataChangeStatus
    
    properties
        % Note that this guy has a dataHasChanged property that is actually
        % a vector of logicals, not a scalar true/false.
    end
    
    methods
        function p = DataChangeTrackedProcStack()
            p.description = 'Data-Change Tracked Processor Stack';
            p.dataHasChanged = false(0);
        end
        
        function p = registerNewProcessor(p, proc)
            p = registerNewProcessor@improc2.ProcessorStack(p,proc);
            
            p.dataHasChanged = [p.dataHasChanged, true];
            recentproc = p.getProcessorByPos(length(p));
            recentproc = recentproc.setDataHasChangedToFalse;
            p = p.setProcessorByPos(recentproc, length(p));
        end
        
        function p = setProcessorByPos(p, proc, index)
            
            assert(isa(proc,'improc2.procs.ProcessorData'), ...
                'First argument must be a processor');
            if  proc.dataHasChanged
                p = p.actionOnDataChangeAt(index);
                proc.dataHasChanged = false;
            end
            
            p = setProcessorByPos@improc2.ProcessorStack(p, proc, index);
        end
    end
    
    methods (Access = protected)
        function p = actionOnDataChangeAt(p, indexOfModifiedProc)
            p.dataHasChanged(indexOfModifiedProc) = true;
        end
    end
    
end

