classdef DirectedAcyclicGraph
    
    properties (SetAccess = private)
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
        
        function node = findNodeByBreadthFirstSearch(p, startingNodeLabel, ...
                meetsRequirementsFUNC)
            startingNode = getNodeByLabel(p, startingNodeLabel);
            nodeNumbersAtCurrentLevel = startingNode.number;
            while true
                nodesMeetingRequirements = [];
                for nodeNumber = nodeNumbersAtCurrentLevel
                    if meetsRequirementsFUNC(p.nodes{nodeNumber})
                        nodesMeetingRequirements(end + 1) = nodeNumber;
                    end
                end
                if ~isempty(nodesMeetingRequirements)
                    break;
                end
                nodeNumbersAtNextLevel = [];
                for nodeNumber = nodeNumbersAtCurrentLevel
                    nodeNumbersAtNextLevel = union(nodeNumbersAtNextLevel, ...
                        p.nodes{nodeNumber}.childNodeNumbers);
                end
                if isempty(nodeNumbersAtNextLevel)
                    error('improc2:NodeNotFound', ...
                        'no node found meeting criterion starting from node %s.', ...
                        startingNodeLabel)
                end
                nodeNumbersAtCurrentLevel = nodeNumbersAtNextLevel;
            end
            
            if length(nodesMeetingRequirements) > 1
                error('more than one found meeting requirements')
            else
                node = p.nodes{nodesMeetingRequirements1};
            end
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

