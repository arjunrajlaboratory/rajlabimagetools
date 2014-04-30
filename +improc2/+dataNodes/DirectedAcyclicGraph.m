classdef DirectedAcyclicGraph
    
    properties
        nodes = {};
    end
    
    properties
        childVsParentConnectivity = [];
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
            assert(~ismember(newNode.label, p.labels), 'improc2:LabelConflict', ...
                'A node with label %s already exists', newNode.label)
            assert(all(ismember(newNode.dependencyNodeLabels, p.labels)), ...
                'at least one of the dependencies does not exist in the graph')
            
            newNodeNumber = numberOfNodes(p) + 1;
            p.nodes(end + 1) = {newNode};
            
            p.childVsParentConnectivity = padarray(p.childVsParentConnectivity, ...
                [1 1], 0, 'post');
            
            for dependencyNodeLabel = newNode.dependencyNodeLabels
                dependencyNodeNumber = find(strcmp(dependencyNodeLabel, p.labels));
                p.nodes{dependencyNodeNumber}.childNodeLabels(end + 1) = {newNode.label};
                p.childVsParentConnectivity(newNodeNumber, dependencyNodeNumber) = 1;
            end
        end
        
        function node = getNodeByLabel(p, label)
            matchingNodeNumber = find(strcmp(label, p.labels));
            assert(~isempty(matchingNodeNumber), 'improc2:NodeNotFound',...
                'Node with label %s not found', label)
            node = p.nodes{matchingNodeNumber};
        end
        
        function p = setNodeDataByLabel(p, label, data)
            matchingNodeNumber = find(strcmp(label, p.labels));
            assert(~isempty(matchingNodeNumber), 'improc2:NodeNotFound',...
                'Node with label %s not found', label)
            p.nodes{matchingNodeNumber}.data = data;
        end
        
        function foundNodes = findShallowestNodesMatchingCondition(p, ...
                startingNodeLabel, searchCriterionFUNC)
            foundNodes = findNodesByTreeDescent(p, startingNodeLabel, searchCriterionFUNC, ...
                'stopAtFirstLevelWithMatches');
        end
        
        function foundNodes = findAllNodesMatchingCondition(p, ...
                startingNodeLabel, searchCriterionFUNC)
            foundNodes = findNodesByTreeDescent(p, startingNodeLabel, searchCriterionFUNC, ...
                'fullSearch');
        end
        
        function h = view(p)
            bg = biograph(p.childVsParentConnectivity', p.labels);
            for i = 1:length(bg.Nodes)
                formatBiographNode(bg.Nodes(i), p.nodes{i});
            end
            h = view(bg);
        end
        
        function n = numberOfNodes(p)
            n = length(p.nodes);
        end
    end
    
    methods (Access = private)
        function foundNodes = findNodesByTreeDescent(p, ...
                startingNodeLabel, searchCriterionFUNC, searchType)
            
            switch searchType
                case 'fullSearch'
                    stopAtFirstMatchingLevel = false;
                case 'stopAtFirstLevelWithMatches'
                    stopAtFirstMatchingLevel = true;
            end
            
            labelsOfNodesToVisit = {startingNodeLabel};
            labelsOfVisitedNodes = {};
            labelsOfNodesAtNextLevel = {};
            foundNodes = {};
            
            while ~isempty(labelsOfNodesToVisit)
                
                currentNode = getNodeByLabel(p, labelsOfNodesToVisit{1});
                
                labelsOfNodesToVisit(1) = [];
                labelsOfVisitedNodes(end + 1) = {currentNode.label};
                labelsOfNodesAtNextLevel = [labelsOfNodesAtNextLevel, ...
                    currentNode.childNodeLabels];
                
                if searchCriterionFUNC(currentNode)
                    foundNodes = [foundNodes, {currentNode}];
                end
                
                if isempty(labelsOfNodesToVisit)
                    if ~isempty(foundNodes) && stopAtFirstMatchingLevel
                        break
                    else
                        labelsOfNodesToVisit = setdiff(labelsOfNodesAtNextLevel, ...
                            labelsOfVisitedNodes);
                        labelsOfNodesToVisit = unique(labelsOfNodesToVisit);
                    end
                end
            end
        end
    end
end

function formatBiographNode(bgNode, dataNode)
    if isa(dataNode.data, 'improc2.dataNodes.ChannelStackContainer')
       bgNode.Color = [1 1 1]; 
    end
    if isa(dataNode.data, 'improc2.interfaces.NodeData') && dataNode.data.needsUpdate
        bgNode.LineColor = [0.76 0.17 0.22];
        bgNode.TextColor = [0.76 0.17 0.22];
        bgNode.LineWidth = 2;
    end
end
