classdef RemembersRunAndDataChange < improc2.LoadSafeDataChangeStatus
   % A RemembersRunAndDataChange is something that can be run and 
   % knows if it has been run, and notifies upon running that its data has
   % changed.
 
    properties (SetAccess = private, GetAccess = private)
        hasrun = false;
    end

    methods (Access = protected)
        function p = runRemembersRun(p, varargin)
        end
    end
    
    methods 
        function p = RemembersRunAndDataChange()
            p.dataHasChanged = true;
        end
    end
    
    methods (Sealed = true)
        function p = run(p, varargin)
            p = p.runRemembersRun(varargin{:});
            p = p.setDoneProcessing();
            p.dataHasChanged = true;
        end
        
        function TF = isProcessed(p)
            TF = p.hasrun;
        end 
    end

    methods (Access = private, Sealed = true)
        function p = setDoneProcessing(p)
            p.hasrun = true;
        end
        function p = setNotDoneProcessing(p)
            p.hasrun = false;
        end
    end
end

