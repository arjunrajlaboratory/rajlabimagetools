classdef Node
    
    properties
        label = '';
        data
        dependencyNodeLabels = {};
        childNodeLabels = {};
    end
    
    methods
        function p = Node()
        end
        function node = set.label(node, label)
            assert(ischar(label), 'The label must be a string')
            node.label = label;
        end
    end 
end

