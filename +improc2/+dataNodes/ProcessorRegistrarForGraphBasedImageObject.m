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
        function registerNewData(p, data, parentNodeLabels, newNodeLabel)
            
            if ischar(parentNodeLabels); 
                parentNodeLabels = {parentNodeLabels}; 
            end
            
            assert(isa(data, 'improc2.interfaces.NodeData'), ...
                'improc2:BadArguments', 'data must implement improc2.interfaces.NodeData')
            
            dependencyNodeLabels = p.locateDependencies(data, parentNodeLabels);
            
            assert(length(dependencyNodeLabels) == length(unique(dependencyNodeLabels)),...
                'improc2:NonUniqueDependencies', ...
                ['The requested dependencies of this node: \n\t%s\n',...
                'contain repetitions.'], strjoin(dependencyNodeLabels, ', '))

            newNode = improc2.dataNodes.Node();
            newNode.data = data;
            newNode.dependencyNodeLabels = dependencyNodeLabels;
            newNode.label = newNodeLabel;
            p.obj.graph = addNode(p.obj.graph, newNode);
        end
        
        function boolean = hasData(p, channelNameOrNodeName, dataClassName)
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
                foundNodes = findShallowestNodesMatchingCondition(graph, ...
                    searchStartNodeLabel, ...
                    @(node) isa(node.data, dependencyClassName));
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
        error('improc2:DependencyNotFound', ...
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
