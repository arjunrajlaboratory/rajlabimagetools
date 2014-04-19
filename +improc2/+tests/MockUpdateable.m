classdef MockUpdateable < handle
    
    properties (SetAccess = private)
        numUpdates = 0;
    end
    
    methods
        function update(p)
            p.numUpdates = p.numUpdates + 1;
        end
    end 
end

