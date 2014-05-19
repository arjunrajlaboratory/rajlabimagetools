classdef DataAdder < handle
    
    properties (Access = private)
        registrar
        iterator
        objectHandle
        dataArray = {};
        parentNodeLabelsArray = {};
        newNodeLabelsArray = {};
        displayedGraphH
    end
    
    properties (Dependent = true)
        channelNames
    end
    
    methods
        function p = DataAdder(dirPathOrAnArrayCollection)
            if nargin < 1
                dirPathOrAnArrayCollection = pwd;
            end
            tools = improc2.launchImageObjectTools(dirPathOrAnArrayCollection);
            p.registrar = tools.dataRegistrar;
            p.objectHandle = tools.objectHandle;
            p.iterator = tools.iterator;
        end
        
        function channelNames = get.channelNames(p)
            channelNames = p.objectHandle.channelNames;
        end
        
        function addDataToObject(p, data, parentNodeLabels, newNodeLabel)
            p.tryToAddDataToCurrentObject(data, parentNodeLabels, newNodeLabel)
            p.dataArray(end+1) = {data};
            p.parentNodeLabelsArray(end+1) = {parentNodeLabels};
            p.newNodeLabelsArray(end+1) = {newNodeLabel};
        end
        
        function view(p)
            if ishandle(p.displayedGraphH)
                delete(p.displayedGraphH)
            end
            
            p.displayedGraphH = p.objectHandle.view();
        end
        
        function repeatForAllObjectsAndQuit(p)
            p.iterator.goToFirstObject();
            p.iterator.goToNextObject(); % we already added to the first object.
            
            while p.iterator.continueIteration
                for i = 1:length(p.dataArray)
                    p.tryToAddDataToCurrentObject(p.dataArray{i}, ...
                        p.parentNodeLabelsArray{i}, p.newNodeLabelsArray{i})
                end
                p.iterator.goToNextObject();
            end
            p.delete();
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
    methods (Access = private)
        function tryToAddDataToCurrentObject(p, data, parentNodeLabels, newNodeLabel)
            if p.objectHandle.hasData(newNodeLabel, class(data))
                fprintf('This object already has data %s\n.', newNodeLabel)
            else
                p.registrar.registerNewData(data, parentNodeLabels, newNodeLabel)
            end
        end
    end
end

