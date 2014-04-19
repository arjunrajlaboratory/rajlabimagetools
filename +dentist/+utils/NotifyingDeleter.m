classdef NotifyingDeleter < handle
    
    properties
        actionsAfterDeletion = {};
        deletionHandler
    end
    
    methods
        function p = NotifyingDeleter(deletionHandler)
            p.deletionHandler = deletionHandler;
            p.actionsAfterDeletion = improc2.utils.DependencyRunner();
        end
        
        function setDeletionsToMatchXYFilter(p, filterFUNC)
           p.deletionHandler.setDeletionsToMatchXYFilter(filterFUNC);
           p.actionsAfterDeletion.runDependencies();
        end
        
        function addActionAfterDeletion(p, handleToObject, funcToRunOnIt)
           p.actionsAfterDeletion.registerDependency(handleToObject, funcToRunOnIt);
        end
    end
end

