classdef DependencyRunner < handle
    %UNTITLED17 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        objectHandles = {};
        functionHandles = {};
    end
    
    methods
        function runDependencies(p)
            for i = 1:length(p.objectHandles)
                objectH = p.objectHandles{i};
                funcToRun = p.functionHandles{i};
                if isvalid(objectH) % false if objectH was deleted
                    funcToRun(objectH);
                end
            end
        end
        function registerDependency(p, handleToDependentObject, functionToRunOnIt)
            p.objectHandles = [p.objectHandles, {handleToDependentObject}];
            p.functionHandles = [p.functionHandles, {functionToRunOnIt}];
        end
    end
end

