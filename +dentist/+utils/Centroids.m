classdef Centroids
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xPositions
        yPositions
    end
    
    methods
        function p = Centroids(xPositions, yPositions)
            if nargin == 0
                xPositions = [];
                yPositions = [];
            end
            p.xPositions = xPositions(:);
            p.yPositions = yPositions(:);
        end
        function p = subsetByIndices(p, indices)
            p.xPositions = p.xPositions(indices);
            p.yPositions = p.yPositions(indices);
        end
        function len = length(p)
            len = length(p.xPositions);
        end
        function [p, indices] = filter(p, filterFuncHandle)
            indices = filterFuncHandle(p);
            p = p.subsetByIndices(indices);
        end
        function p = concatenate(p, q)
            p.xPositions = [p.xPositions; q.xPositions];
            p.yPositions = [p.yPositions; q.yPositions];
        end
        
    end
    
end
