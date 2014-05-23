classdef GraphBasedImageObject
    
    properties
        graph
        annotations
        metadata = struct();
    end
    
    properties (Dependent = true)
        object_mask
    end
    
    methods
        function p = GraphBasedImageObject()
            p.annotations = struct('isGood', improc2.TypeCheckedLogical(true));
        end
        
        function object_mask = get.object_mask(p)
            object_mask = p.graph.nodes{1}.data;
        end
        
        function p = set.object_mask(p, object_mask)
            assert(isa(object_mask, 'improc2.dataNodes.ImageObjectBaseData'))
            p.graph.nodes{1}.data = object_mask;
        end
    end
end

