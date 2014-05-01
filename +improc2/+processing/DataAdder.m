classdef DataAdder < handle
    
    properties (Access = private)
        registrar
        iterator
        objectHandle
        dataArray = {};
        parentNodeLabelsArray = {};
        newNodeLabelsArray = {};
    end
    
    methods
        function p = DataAdder(dirPathOrAnArrayCollection)
            if nargin < 1
                dirPathOrAnArrayCollection = pwd;
            end
            tools = improc2.launchImageObjectTools(dirPathOrAnArrayCollection);
            p.registrar = tools.processorRegistrar;
            p.objectHandle = tools.objectHandle;
            p.iterator = tools.iterator;
        end
        
        function addDataToObject(p, data, parentNodeLabels, newNodeLabel)
            p.tryToAddDataToCurrentObject(data, parentNodeLabels, newNodeLabel)
            p.dataArray(end+1) = {data};
            p.parentNodeLabelsArray(end+1) = {parentNodeLabels};
            p.newNodeLabelsArray(end+1) = {newNodeLabel};
        end
        
        function repeatForAllObjects(p)
            p.iterator.goToFirstObject();
            p.iterator.goToNextObject(); % we already added to the first object.
            
            while p.iterator.continueIteration
                for i = 1:length(p.dataArray)
                    p.tryToAddDataToCurrentObject(p.dataArray{i}, ...
                        p.parentNodeLabelsArray{i}, p.newNodeLabelsArray{i})
                end
                p.iterator.goToNextObject();
            end
        end
    end
    
    methods (Access = private)
        function tryToAddDataToCurrentObject(p, data, parentNodeLabels, newNodeLabel)
            if p.objectHandle.hasProcessorData(newNodeLabel, class(data))
                fprintf('This object already has data %s', newNodeLabel)
            else
                p.registrar.registerNewProcessor(data, parentNodeLabels, newNodeLabel)
            end
        end
    end
end

