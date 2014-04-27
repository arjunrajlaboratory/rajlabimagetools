classdef DirectedAcyclicGraph
    
    properties (SetAccess = private)
        nodes = {};
    end
    
    methods
        function p = DirectedAcyclicGraph()
        end
        function p = addNode(p, newNode)
            newNode.number = length(p.nodes) + 1;
            p.nodes(end + 1) = {newNode};
        end
        function dependentsVsDependencies = makeDependentsVsDependenciesMatrix(p)
            dependentsVsDependencies = zeros(length(p));
            for nodeNumber = 1:length(p)
                dependenciesOfThisNode = p.nodes{nodeNumber}.dependencyNodeNumbers;
                dependentsVsDependencies(nodeNumber, dependenciesOfThisNode) = 1;
            end
        end
        function view(p)
            nodeIDs = cellfun(@(x) x.label, p.nodes, 'UniformOutput', false);
            bg = biograph(makeDependentsVsDependenciesMatrix(p)', nodeIDs);
            view(bg)
        end
        function n = length(p)
            n = length(p.nodes);
        end
    end
    methods (Access = private)
    end
end

