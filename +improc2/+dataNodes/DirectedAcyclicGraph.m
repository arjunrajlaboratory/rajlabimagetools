classdef DirectedAcyclicGraph
    
    properties
        nodes = {};
    end
    
    properties (Dependent = true)
        labels
    end
    
    methods
        function p = DirectedAcyclicGraph()
        end
        
        function labels = get.labels(p)
            N = numberOfNodes(p);
            labels = cell(1, N);
            for i = 1:N
                labels{i} = p.nodes{i}.label;
            end
        end
        
        function p = addNode(p, newNode)
            assert(ischar(newNode.label) && ~ismember(newNode.label, p.labels),...
                'improc2:LabelConflict', 'A node with label %s already exists', ...
                newNode.label)
            newNode.number = numberOfNodes(p) + 1;
            for dependencyNodeNumber = newNode.dependencyNodeNumbers
                p.nodes{dependencyNodeNumber}.childNodeNumbers(end + 1) = newNode.number;
            end
            p.nodes(end + 1) = {newNode};
        end
        
        function node = getNodeByLabel(p, label)
            matchingNodeNumber = find(strcmp(label, p.labels));
            assert(~isempty(matchingNodeNumber), 'improc2:NodeNotFound',...
                'Node with label %s not found', label)
            node = p.nodes{matchingNodeNumber};
        end
        
        function foundNodes = findNodesByTreeDescent(p, ...
                startingNodeLabel, meetsRequirementsFUNC)
            
            startingNode = getNodeByLabel(p, startingNodeLabel);
            nodeNumbersAtCurrentLevel = startingNode.number;
            nodesMeetingRequirements = [];
            while true
                nodeNumbersAtNextLevel = [];
                for nodeNumber = nodeNumbersAtCurrentLevel'
                    if meetsRequirementsFUNC(p.nodes{nodeNumber})
                        nodesMeetingRequirements(end + 1) = nodeNumber;
                    end
                    nodeNumbersAtNextLevel = union(nodeNumbersAtNextLevel, ...
                        p.nodes{nodeNumber}.childNodeNumbers);
                end
                if isempty(nodeNumbersAtNextLevel)
                    break
                end
                nodeNumbersAtCurrentLevel = nodeNumbersAtNextLevel;
            end
            
            nodesMeetingRequirements = unique(nodesMeetingRequirements);
            foundNodes = p.nodes(nodesMeetingRequirements);
        end
        
        function dependentsVsDependencies = makeDependentsVsDependenciesMatrix(p)
            dependentsVsDependencies = zeros(numberOfNodes(p));
            for nodeNumber = 1:numberOfNodes(p)
                dependenciesOfThisNode = p.nodes{nodeNumber}.dependencyNodeNumbers;
                dependentsVsDependencies(nodeNumber, dependenciesOfThisNode) = 1;
            end
        end
        
        function view(p)
            nodeIDs = cellfun(@(x) x.label, p.nodes, 'UniformOutput', false);
            bg = biograph(makeDependentsVsDependenciesMatrix(p)', nodeIDs);
            view(bg)
        end
        
        function n = numberOfNodes(p)
            n = length(p.nodes);
        end
    end
    
    methods (Access = private)
    end
end

