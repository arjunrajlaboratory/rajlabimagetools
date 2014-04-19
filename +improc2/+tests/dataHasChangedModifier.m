classdef dataHasChangedModifier < improc2.DataChangeManager
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x = improc2.LoadSafeDataChangeStatus;
    end
    
    methods
        function p = setNoChange(p)
            p.x.dataHasChanged = false;
        end
        function p = setChange(p)
            p.x.dataHasChanged = true;
        end
    end
    
end

