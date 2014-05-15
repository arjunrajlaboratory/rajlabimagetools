classdef GraphBasedImageObject
    
    properties
        graph
        annotations
        metadata = struct();
    end
    
    methods
        function p = GraphBasedImageObject()
            p.annotations = struct('isGood', improc2.TypeCheckedLogical(true));
        end
    end
end

