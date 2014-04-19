classdef InMemoryObjectArrayCollection < improc2.interfaces.ObjectArrayCollection
    
    properties (SetAccess = private, GetAccess = private)
        cellArray;
    end
    
    methods
        function p = InMemoryObjectArrayCollection(cellArray)
            p.cellArray = cellArray;
        end
        
        function objects = getObjectsArray(p, n)
            objects = p.cellArray{n};
            fprintf('loaded array %d from memory.\n', n)
        end
        
        function setObjectsArray(p, objects, n)
            p.cellArray{n} = objects;
            fprintf('saved array %d to memory.\n', n)
        end
        
        function len = length(p)
            len = length(p.cellArray);
        end
    end
    
end

