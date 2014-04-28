classdef ProcessorRegistrarForGraphBasedImageObject < improc2.interfaces.ProcessorRegistrar
    
    properties (Access = private)
        objHolder
    end
    
    properties (Access = private, Dependent = true)
        obj
    end
    
    methods
        function p = ProcessorRegistrarForGraphBasedImageObject(objHolder)
            p.objHolder = objHolder;
        end
        function obj = get.obj(p)
            obj = p.objHolder.obj;
        end
        function set.obj(p, obj)
            p.objHolder.obj = obj;
        end
        function registerNewProcessor(p, data, parentNodeLabels, newNodeLabel)
            if ischar(parentNodeLabels); 
                parentNodeLabels = {parentNodeLabels}; 
            end
            if isa(data, 'improc2.interfaces.ProcessedData')
                dependencyNodeLabels = p.locateDependencies(data, parentNodeLabels);
            else
                dependencyNodeLabels = parentNodeLabels;
            end
            assert(all(ismember(dependencyNodeLabels, p.obj.graph.labels)), ...
                ['at least one of the labels does not correspond',...
                'to an existing node in the data']);
            dependencyNodeNumbers = [];
            for i = 1:length(dependencyNodeLabels)
                dependencyNodeNumbers(i) = find(strcmp(dependencyNodeLabels{i}, p.obj.graph.labels));
            end
            newNode = improc2.dataNodes.Node();
            newNode.data = data;
            newNode.dependencyNodeNumbers = dependencyNodeNumbers;
            newNode.label = newNodeLabel;
            p.obj.graph = addNode(p.obj.graph, newNode);
        end
        
        function boolean = hasProcessorData(p, channelNameOrNodeName, dataClassName)
        end
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
    methods (Access = private)
        function dependencyNodeLabels = locateDependencies(p, data, parentNodeLabels)
            dependencyClassNames = data.dependencyClassNames;
            dependencyNodeLabels = cell(1, length(dependencyClassNames));
            graph = p.obj.graph;
            parentNodeLabels = validateAndFormatParentLabels(...
                dependencyClassNames, parentNodeLabels);
            for i = 1:length(dependencyClassNames)
                dependencyClassName = dependencyClassNames{i};
                searchStartNodeLabel = parentNodeLabels{i};
                foundNodes = findNodesByTreeDescent(graph, searchStartNodeLabel, ...
                    @(node) isa(node.data, dependencyClassName),...
                    'stopAtFirstLevelWithMatchingNodes');
                errorIfNoNodeFoundToMeetDependency(foundNodes, ...
                    dependencyClassName, searchStartNodeLabel)
                errorIfMoreThanOneNodeFoundToMeetDependency(foundNodes, ...
                    dependencyClassName, searchStartNodeLabel)
                dependencyNodeLabels{i} = foundNodes{1}.label;
            end
        end
    end
end

function parentNodeLabels = validateAndFormatParentLabels(dependencyClassNames, ...
        parentNodeLabels)
    if ischar(parentNodeLabels)
        parentNodeLabels = {parentNodeLabels};
    end
    if length(parentNodeLabels) ~= length(dependencyClassNames)
        if length(parentNodeLabels) == 1
            parentNodeLabels = repmat(parentNodeLabels, 1, length(dependencyClassNames));
        else
            error(['must provide either 1 parent node label,', ...
                'or a cell array with as many parent node labels', ...
                'as there are dependencies'])
        end
    end
end

function errorIfNoNodeFoundToMeetDependency(foundNodes, ...
        dependencyClassName, searchStartNodeLabel)
    if isempty(foundNodes)
        error('improc2:NodeNotFound', ...
            ['No Node with data of required type (%s)\n',...
            'found starting from node %s.'], ...
            dependencyClassName, searchStartNodeLabel)
    end
end

function errorIfMoreThanOneNodeFoundToMeetDependency(foundNodes, ...
        dependencyClassName, searchStartNodeLabel)
    if length(foundNodes) > 1
        matchingNodeLabels = cellfun(@(node) node.label, foundNodes, 'UniformOutput', false);
        error('improc2:AmbiguousDependencySpecification', ...
            ['Ambiguous Dependency Specification!\n', ...
            'Starting from node %s, nodes %s\n', ...
            'are all of the required dependency type (%s).\n', ...
            'Specify One of these as the starting Node instead.'], ...
            searchStartNodeLabel, strjoin(matchingNodeLabels, ', '),...
            dependencyClassName);
    end
end