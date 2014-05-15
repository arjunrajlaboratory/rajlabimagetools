classdef DataNodeAdder < handle
    properties (Access = private)
        objectHandle
        iterator
        registrar
    end
    
    methods
        function p = DataNodeAdder(dirPathOrAnArrayCollection)
            if nargin < 1
                dirPathOrAnArrayCollection = pwd;
            end
            tools = improc2.launchImageObjectTools(dirPathOrAnArrayCollection);
            assert(isa(tools.objectHandle, 'improc2.dataNodes.HandleToGraphBasedImageObject'),...
                'improc2:NoLegacySupport', 'this function only works on graph-based image objects')
            p.objectHandle = tools.objectHandle;
            p.iterator = tools.iterator;
            p.registrar = tools.processorRegistrar;
        end
        
        function addDataNode(p, data, parentNodeLabels, newNodeLabel)
            p.iterator.goToFirstObject();
            while p.iterator.continueIteration
                fprintf('Working on %s\n', p.iterator.getLocationDescription())
                if ~ p.objectHandle.hasProcessorData(newNodeLabel)
                    p.registrar.registerNewProcessor(data, parentNodeLabels, newNodeLabel)
                end
                p.iterator.goToNextObject();
            end
        end 
    end
end