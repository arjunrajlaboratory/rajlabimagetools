classdef MockDeleter < handle
    %UNTITLED17 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        xs
        ys
        deleted
    end
    
    methods
        function p = MockDeleter(xs,ys)
            p.xs = xs;
            p.ys = ys;
            p.deleted = false(size(xs));
        end
        
        function deleteByXYFilter(p, twoArgFUNC)
            p.deleted = twoArgFUNC(p.xs, p.ys);
        end
    end
    
end

