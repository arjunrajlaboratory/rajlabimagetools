classdef ZSlicer < handle
    
    properties (SetAccess = private)
        sliceToTake = 1;
    end
    
    methods
        function p = ZSlicer()
        end
        function setSliceToTake(p, sliceToTake)
            p.sliceToTake = sliceToTake;
        end
        function slicedImg = sliceImage(p, img)
            numSlicesAvailable = size(img, 3);
            p.sliceToTake = min(p.sliceToTake, numSlicesAvailable);
            slicedImg = img(:, :, p.sliceToTake);
        end
        function [XsInSlice, YsInSlice] = slicePoints(p, Xs, Ys, Zs)
            inSlice = (Zs == p.sliceToTake);
            XsInSlice = Xs(inSlice);
            YsInSlice = Ys(inSlice);
        end
    end
end

