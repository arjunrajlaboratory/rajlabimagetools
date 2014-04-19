%--------------------------------------------------------------------------
% Used by DensitySingleTile
% Properties:
%       ulIndex         [row,col] of upper-left of bounding box.  This
%                       value is an absolute value.  Relative to scan not 
%                       individual tile
%       boxDimensions   [row_width,col_width] of bounding box
%       mask            Mask of nucleus (0.1 scaled binary image of
%                       bounding box)
%       centroid        [row,col] of centroid
%--------------------------------------------------------------------------
classdef Nucleus
    properties
        ulIndex
        row_width
        col_width
        mask
        centroid
    end
    
    methods
        function p = Nucleus(ulIndex,boxDimensions, mask,centroid)
            p.ulIndex = ulIndex;
            p.row_width = boxDimensions(1);
            p.col_width = boxDimensions(2);
            p.mask = mask;
            p.centroid = centroid;
        end
    end
    
end

