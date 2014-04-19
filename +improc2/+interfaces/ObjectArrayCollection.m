classdef ObjectArrayCollection < handle
    
    methods (Abstract = true)
        objects = getObjectsArray(arrayCollection, n)
        setObjectsArray(arrayCollection, objects, n)
        len = length(arrayCollection)
    end
end

