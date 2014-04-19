classdef MinimalLoadSafeDataChangeStatus < improc2.LoadSafeDataChangeStatus
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        value = 0;
    end
    
    methods
        function p = MinimalLoadSafeDataChangeStatus()
        end
        
        function p = set.value(p, val)
            fprintf(1,'Setting the value\n');
            p.value = val;
            p.dataHasChanged = true;
        end
        
        function p = setNotChanged(p)
            p.dataHasChanged = false;
        end
    end
    
end

