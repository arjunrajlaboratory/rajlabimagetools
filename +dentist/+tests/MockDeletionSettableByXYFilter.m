classdef MockDeletionSettableByXYFilter < handle
    %UNTITLED47 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        deleted
        xs
        ys
    end
    
    methods
        function p = MockDeletionSettableByXYFilter(xs, ys)
            p.xs = xs;
            p.ys = ys;
            p.deleted = false(size(p.xs));
        end
        
        function setDeletionsToMatchXYFilter(p, filterFUNC)
            p.deleted = filterFUNC(p.xs, p.ys);
        end
    end
    
end

