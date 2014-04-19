classdef ManagedProcessorQueue < improc2.DataChangeTrackedProcStack
    %UNTITLED16 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function p = ManagedProcessorQueue()
        end
        
        function p = registerNewProcessor(p, proc)
            p = p.registerNewProcessor@improc2.DataChangeTrackedProcStack(proc);    
            p.errorIfInvalidNewestProcessor();
        end
        
        function procscell = getProcsNecessaryToRun(p, index)
            procindices = p.getProcIndicesNecessaryToRun(index);
            procscell = cell(size(procindices));
            for i = 1:length(procindices)
                procscell{i} = p.getProcessorByPos(procindices(i));
            end
        end
        
    end
    
    methods (Access = protected)
        
        function procindices = getProcIndicesNecessaryToRun(p, index)
            proc = p.getProcessorByPos(index);

            procTypesRequested = proc.procDatasIDependOn;
            procindices = zeros(size(procTypesRequested));
            for i = 1:length(procTypesRequested)
                try
                    procindices(i) = p.indexFromClassName( ...
                        procTypesRequested{i}, 'last', 1, index-1);
                catch err
                    if strcmp(err.identifier, 'improc2:ProcNotFound')
                        error('improc2:DependencyNotFound', ...
                            ['Processor of class %s necessary to run this\n',...
                            'post-processor not found earlier in the queue.'], ...
                            procTypesRequested{i})
                    else
                        rethrow(err)
                    end
                end
            end
        end
        
        function errorIfInvalidNewestProcessor(p)
            lastprocindex = length(p);
            try
                p.getProcIndicesNecessaryToRun( lastprocindex );
            catch err
                rethrow(err)
            end
        end
        
        % override
        function p = actionOnDataChangeAt(p, indexOfModifiedProc)
            
            p = actionOnDataChangeAt@improc2.DataChangeTrackedProcStack(...
                p, indexOfModifiedProc);
            
            for i = (indexOfModifiedProc + 1) : length(p)

                procIndicesThisDependsOn = p.getProcIndicesNecessaryToRun(i);
                if ismember(indexOfModifiedProc, procIndicesThisDependsOn)
                    proc = p.getProcessorByPos(i);
                    proc = proc.setNeedsUpdateTrue;
                    p = p.setProcessorByPos(proc, i);
                    % Now update the queue as though this postprocessor's
                    % data has changed.
                    p = p.actionOnDataChangeAt(i);
                end
            end
        end
    end
    
end

