classdef MockContraster
    
    properties (Access = private)
        id
    end
    
    methods
        function p = MockContraster(id)
            p.id = id;
        end
        
        function out = contrast(p, varargin)
            out = p.id;
        end
    end
    
end

