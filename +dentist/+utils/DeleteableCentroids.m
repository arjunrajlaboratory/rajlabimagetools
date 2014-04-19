classdef DeleteableCentroids
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        centroids;
    end
    
    properties (SetAccess = private)
       deletionMask
       numSpots
    end
    
    properties (Dependent = true)
        xPositions;
        yPositions;
    end
    
    methods
        function p = DeleteableCentroids(varargin)
            p.centroids = dentist.utils.Centroids(varargin{:});
            p.deletionMask = false([1 length(p.centroids)]);
        end
        function p = setNumSpots(numSpots)
            p.numSpots = numSpots;
        end
        function p = deleteByIndices(p, indices)
            toDelete = p.activeIndicesToAllIndices(indices);
            p.deletionMask(toDelete) = true;
        end
        
        function xPos = get.xPositions(p)
            xPos = p.centroids.xPositions(~p.deletionMask);
        end
        
        function yPos = get.yPositions(p)
            yPos = p.centroids.yPositions(~p.deletionMask);
        end
        
        function p = subsetByIndices(p, activeIndices)
            allIndices = p.activeIndicesToAllIndices(activeIndices);
            p.centroids = p.centroids.subsetByIndices(allIndices);
            p.deletionMask = p.deletionMask(allIndices);
        end
        
        function p = unDeleteAll(p)
            p.deletionMask = false(size(p.deletionMask));
        end
        
        function p = concatenate(p, q)
            p.deletionMask = [p.deletionMask, q.deletionMask];
            p.centroids = p.centroids.concatenate(q.unDeleteAll);
        end
        
        function p = filter(p, filterFuncHandle)
            [p.centroids, indices] = filter(p.centroids, filterFuncHandle);
            p.deletionMask = p.deletionMask(indices); 
        end
        
        function out = activeIndicesToAllIndices(p, indices)
            arr = 1:p.centroids.length();
            arr(p.deletionMask) = [];
            out = arr(indices);
        end
    end
    
end
