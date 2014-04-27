classdef GraphBasedImageObject
    
    properties
        graph;
        annotations;
    end
    
    methods
        function p = GraphBasedImageObject()
            p.annotations = struct('isGood', improc2.TypeCheckedLogical(true));
        end
    end
end

