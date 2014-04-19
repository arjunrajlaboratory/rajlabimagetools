classdef IntegerIterator < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        count = 0;
    end
    
    methods
        function val = next(p)
           val = p.count;
           p.count = p.count + 1;
        end
    end
    
end

