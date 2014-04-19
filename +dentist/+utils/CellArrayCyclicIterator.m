classdef CellArrayCyclicIterator < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        elementArray;
        currElementIndex;
    end
    
    methods
        function p = CellArrayCyclicIterator(elementArray)
            assert(~isempty(elementArray), 'Input must not be empty');
            assert(iscell(elementArray), 'Input must be cell array');
            p.elementArray = elementArray;
            p.currElementIndex = 0;
        end
        
        function element = next(p)
            if p.currElementIndex < length(p.elementArray)
                p.currElementIndex = p.currElementIndex + 1;
            else
                p.currElementIndex = 1;
            end
            element = p.elementArray{p.currElementIndex};
        end
        
        function reset(p)
            p.currElementIndex = 0;
        end
            
    end
    
end

