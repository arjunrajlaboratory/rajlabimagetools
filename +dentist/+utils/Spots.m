classdef Spots
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        yPositions
        xPositions
        intensities
    end
    
    methods
        function p = Spots(xPositions, yPositions, intensities)
            if nargin == 0
                xPositions = [];
                yPositions = [];
                intensities = [];
            end
            p.xPositions = xPositions(:);
            p.yPositions = yPositions(:);
            p.intensities = intensities(:);
        end
        function p = subsetByIndices(p, indices)
            p.xPositions = p.xPositions(indices);
            p.yPositions = p.yPositions(indices);
            p.intensities = p.intensities(indices);
        end
        function len = length(p)
            len = length(p.xPositions);
        end
        function [p, indices] = filter(p, filterFuncHandle)
            indices = filterFuncHandle(p);
            p = p.subsetByIndices(indices);
        end
        function p = concatenate(p, spots)
            p.xPositions = [p.xPositions; spots.xPositions];
            p.yPositions = [p.yPositions; spots.yPositions];
            p.intensities = [p.intensities; spots.intensities];
        end
    end
    
end

