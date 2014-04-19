classdef MockDeletionCriteriaProvider < handle
    %UNTITLED16 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private, SetAccess = private);
        funchandle
    end
    
    methods
        function p = MockDeletionCriteriaProvider(funchandle)
            p.funchandle = funchandle;
        end
        
        function funchandle = getXYFilter(p)
            funchandle = p.funchandle;
        end 
    end
    
end

