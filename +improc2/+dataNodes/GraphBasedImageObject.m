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
        
        function errorIfInvalid(p)
            nodes = p.graph.nodes;
            for i = 1:length(nodes)
               node = nodes{i};
               data = node.data;
               dataIsCompatible = ...
                   isa(data, 'improc2.dataNodes.ImageObjectBaseData') || ...
                   isa(data, 'improc2.dataNodes.ChannelStackContainer') || ...
                   isa(data, 'improc2.interfaces.NodeData');
               if ~dataIsCompatible
                   errmsg = sprintf(['data at node %s is of type %s, ', ...
                       'rather than being:\n',...
                       'improc2.dataNodes.ImageObjectBaseData\n', ...
                       'improc2.dataNodes.ChannelStackContainer.\n', ...
                       'OR\n a subclass of improc2.interfaces.NodeData\n', ...
                       'Check that the class files for all node data you saved', ...
                       'are in your matlab path.'], node.label, class(data));
                   error('improc2:BadImageObject', errmsg)
               end
            end
        end
    end
end

