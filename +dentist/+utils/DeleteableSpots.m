classdef DeleteableSpots
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        spots;
    end
    
    properties (SetAccess = private)
       deletionMask
    end
    
    properties (Dependent = true)
        xPositions;
        yPositions;
        intensities;
    end
    
    methods
        function p = DeleteableSpots(varargin)
            p.spots = dentist.utils.Spots(varargin{:});
            p.deletionMask = false([1 length(p.spots)]);
        end
        function p = deleteByIndices(p, indices)
            toDelete = p.activeIndicesToAllIndices(indices);
            p.deletionMask(toDelete) = true;
        end
        
        function xPos = get.xPositions(p)
            xPos = p.spots.xPositions(~p.deletionMask);
        end
        
        function yPos = get.yPositions(p)
            yPos = p.spots.yPositions(~p.deletionMask);
        end
        
        function intensities = get.intensities(p)
            intensities = p.spots.intensities(~p.deletionMask);
        end
        
        function p = subsetByIndices(p, activeIndices)
            allIndices = p.activeIndicesToAllIndices(activeIndices);
            p.spots = p.spots.subsetByIndices(allIndices);
            p.deletionMask = p.deletionMask(allIndices);
        end
        
        function p = unDeleteAll(p)
            p.deletionMask = false(size(p.deletionMask));
        end
        
        function p = concatenate(p, q)
            p.deletionMask = [p.deletionMask, q.deletionMask];
            p.spots = p.spots.concatenate(q.unDeleteAll);
        end
  
        function [p] = filter(p, filterFuncHandle)
            [p.spots, indices] = filter(p.spots, filterFuncHandle);
            p.deletionMask = p.deletionMask(indices); 
        end
        
        function out = activeIndicesToAllIndices(p, indices)
            arr = 1:p.spots.length();
            arr(p.deletionMask) = [];
            out = arr(indices);
        end
    end
    
end

