classdef MockSpotCoordinatesAndImageProvider < handle
    
    properties (Access = private)
        I
        J
        K
        img
    end
    
    methods
        function p = MockSpotCoordinatesAndImageProvider(I,J,K, img)
            p.I = I;
            p.J = J;
            p.K = K;
            p.img = img;
        end
        function [I, J, K] = getSpotCoordinates(p)
            I = p.I;
            J = p.J;
            K = p.K;
        end
        function num = getNumSpots(p)
            num = length(p.I);
        end
        function img = getImage(p)
            img = p.img;
        end
    end
    
end


