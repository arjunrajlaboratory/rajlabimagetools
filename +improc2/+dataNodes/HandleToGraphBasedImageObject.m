classdef HandleToGraphBasedImageObject < improc2.interfaces.ImageObjectHandle
    
    properties (Access = private)
        objHolder
    end
    
    properties (Access = private, Dependent = true)
        obj
    end
    
    properties (Dependent = true)
        channelNames
    end
    
    methods
        function p = HandleToGraphBasedImageObject(objHolder)
            p.objHolder = objHolder;
        end
        
        function channelNames = get.channelNames(p)
            channelNodes = findShallowestNodesMatchingCondition(p.obj.graph, 'imageObject', ...
                @(node) isa(node.data, 'improc2.dataNodes.ChannelStackContainer'));
            channelNames = cellfun(@(node) node.label, channelNodes, 'UniformOutput', false);
        end
        function obj = get.obj(p)
            obj = p.objHolder.obj;
        end
        function set.obj(p, obj)
            p.objHolder.obj = obj;
        end
        
        function metadata = getMetaData(p)
            metadata = p.obj.metadata;
        end
        
        function imFileMask = getMask(p)
            imFileMask = p.obj.graph.nodes{1}.data.imfilemask;
        end
        function bbox = getBoundingBox(p)
            bbox = p.obj.graph.nodes{1}.data.boundingbox;
        end
        function objMask = getCroppedMask(p)
            objMask = p.obj.graph.nodes{1}.data.mask;
        end
        
        function fileName = getImageFileName(p, channelName)
            channelNode = getNodeByLabel(p.obj.graph, channelName);
            fileName = channelNode.data.fileName;
        end
        function dirPath = getImageDirPath(p)
            firstChannel = p.channelNames{1};
            channelNode = getNodeByLabel(p.obj.graph, firstChannel);
            dirPath = channelNode.data.dirPath;
        end
        
        function [pData, foundNodeLabel] = getProcessorData(p, nodeLabel, dataClassName)
            if nargin < 3
                node = p.findDataNode(nodeLabel);
            else
                node = p.findDataNode(nodeLabel, dataClassName);
            end
            pData = node.data;
            foundNodeLabel = node.label;
        end
        
        function setProcessorData(p, pData, nodeLabel, dataClassName)
            if nargin < 4
                nodeToUpdate = p.findDataNode(nodeLabel);
            else
                nodeToUpdate = p.findDataNode(nodeLabel, dataClassName);
            end
            assert(strcmp(class(pData), class(nodeToUpdate.data)), ...
                'improc2:BadArguments', ...
                'Replacement Data must be of class %s, not %s', ...
                class(nodeToUpdate.data), class(pData))
            nodeToUpdate.data = pData;
            p.notifyAllDependentNodes(nodeToUpdate.label)
            p.obj.graph = setNodeDataByLabel(p.obj.graph, ...
                nodeToUpdate.label, nodeToUpdate.data);
        end
        
        function boolean = hasProcessorData(p, nodeLabel, dataClassName)
            if nargin < 3
                dataClassName = 'improc2.interfaces.NodeData';
            end
            graph = p.obj.graph;
            if ~ismember(nodeLabel, p.obj.graph.labels)
                boolean = false;
            else
                foundNodes = findShallowestNodesMatchingCondition(graph, ...
                    nodeLabel, @(node) isa(node.data, dataClassName));
                boolean = ~isempty(foundNodes);
            end
        end
        
        function runProcessor(p, imageProviderChannelArray, nodeLabel, dataClassName)
            extraGetArgs = {};
            if nargin == 4
                extraGetArgs{1} = dataClassName;
            end
            [pDataToProcess, labelOfDataToProcess] = p.getProcessorData(nodeLabel, extraGetArgs{:});
            assert(isa(pDataToProcess, 'improc2.interfaces.ProcessedData'), ...
                'improc2:DataNotRunnable', ...
                'Data at node %s is not an improc2.interfaces.ProcessedData.', nodeLabel)
            dependencyData = p.getDataFromDependencies(labelOfDataToProcess);
            dependencyData = p.fillAnyStackContainers(dependencyData, imageProviderChannelArray);
            pData = run(pDataToProcess, dependencyData{:});
            pData.needsUpdate = false;
            p.notifyAllDependentNodes(labelOfDataToProcess);
            p.obj.graph = setNodeDataByLabel(p.obj.graph, labelOfDataToProcess, pData);
        end
        
        function updateAllProcessedData(p, imageProviderChannelArray)
            
            labelsOfDataToProcess = {};
            for i = 1:length(p.obj.graph.nodes)
                node = p.obj.graph.nodes{i};
                if isa(node.data, 'improc2.interfaces.ProcessedData') && ...
                        node.data.needsUpdate
                    labelsOfDataToProcess(end + 1) = {node.label};
                end
            end
            
            while ~isempty(labelsOfDataToProcess)
                labelsOfDataToProcessInNextRound = {};
                for nodeLabel = labelsOfDataToProcess
                    if p.dependenciesAreUpToDate(nodeLabel)
                        p.runProcessor(imageProviderChannelArray, nodeLabel)
                    else
                        labelsOfDataToProcessInNextRound(end+1) = nodeLabel;
                    end
                end
                if length(labelsOfDataToProcessInNextRound) < length(labelsOfDataToProcess)
                    labelsOfDataToProcess = labelsOfDataToProcessInNextRound;
                else
                    fprintf(['Could not update processors:\n\t%s \nbecause ',...
                        'they have non-processedData dependencies that ', ...
                        'need an update or review.\n'], strjoin(labelsOfDataToProcess, ', '))
                    break
                end
            end
        end
        
        function h = view(p)
            h = view(p.objHolder.obj.graph);
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p);
        end
        
    end
    
    methods (Access  = private)
        
        function boolean = dependenciesAreUpToDate(p, childNodeLabel)
            childNode = getNodeByLabel(p.obj.graph, childNodeLabel);
            boolean = true;
            for dependencyLabel = childNode.dependencyNodeLabels
                dependencyNode = getNodeByLabel(p.obj.graph, dependencyLabel{1});
                if isa(dependencyNode.data, 'improc2.interfaces.NodeData') && ...
                        dependencyNode.data.needsUpdate
                    boolean = false;
                    break
                end
            end
        end
        
        function node = findDataNode(p, nodeLabel, dataClassName)
            if nargin < 3
                dataClassName = 'improc2.interfaces.NodeData';
            end
            graph = p.obj.graph;
            foundNodes = findShallowestNodesMatchingCondition(graph, ...
                nodeLabel, @(node) isa(node.data, dataClassName));
            assert(~isempty(foundNodes), 'improc2:NodeNotFound', ...
                ['Could not locate data of type %s starting from', ...
                ' node %s.'], dataClassName, nodeLabel)
            if length(foundNodes) > 1
                matchingNodeLabels = cellfun(@(node) node.label, foundNodes, 'UniformOutput', false);
                error('improc2:AmbiguousDataSpecification', ...
                    ['Starting from node %s, nodes %s\n', ...
                    'are all of the required data type (%s).\n', ...
                    'Specify one of these as the node Label or require a more specific data type.'], ...
                    nodeLabel, strjoin(matchingNodeLabels, ', '),...
                    dataClassName);
            end
            node = foundNodes{1};
        end
        
        function dependencyData = fillAnyStackContainers(p, dependencyData, ...
                imageProviderChannelArray)
            for i = 1:length(dependencyData)
                data = dependencyData{i};
                if isa(data, 'improc2.dataNodes.ChannelStackContainer')
                    imageProvider = ...
                        imageProviderChannelArray.getByChannelName(data.channelName);
                    data.croppedImage = imageProvider.getImage(p, data.channelName);
                    data.croppedMask = p.getCroppedMask();
                    dependencyData{i} = data;
                end
            end
        end
        
        function dependencyData = getDataFromDependencies(p, childNodeLabel)
            childNode = getNodeByLabel(p.obj.graph, childNodeLabel);
            dependencyData = {};
            for dependencyLabel = childNode.dependencyNodeLabels
                dependencyNode = getNodeByLabel(p.obj.graph, dependencyLabel{1});
                if isa(dependencyNode.data, 'improc2.interfaces.NodeData') && ...
                        dependencyNode.data.needsUpdate
                    error('improc2:DependencyNeedsUpdate', ...
                        'Dependency \"%s\" to run processor \"%s\" needs update or review', ...
                        dependencyNode.label, childNodeLabel)
                end
                dependencyData(end + 1) = {dependencyNode.data};
            end
        end
        
        function notifyAllDependentNodes(p, parentNodeLabel)
            dependentNodes = findAllNodesMatchingCondition(...
                p.obj.graph, parentNodeLabel, ...
                @(node) isa(node.data, 'improc2.interfaces.NodeData'));
            for i = 1:length(dependentNodes)
                dependentNodes{i}.data.needsUpdate = true;
                if ~strcmp(dependentNodes{i}.label, parentNodeLabel)
                    p.obj.graph = setNodeDataByLabel(p.obj.graph, ...
                        dependentNodes{i}.label, dependentNodes{i}.data);
                end
            end
        end
    end
end

