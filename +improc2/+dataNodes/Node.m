classdef Node
    
    properties
        label = '';
        data = {};
        number = NaN;
        dependencyNodeNumbers = [];
        childNodeNumbers = [];
    end
    
    methods
        function p = Node()
        end
    end 
end

