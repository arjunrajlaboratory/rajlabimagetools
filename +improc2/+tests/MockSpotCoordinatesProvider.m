classdef MockSpotCoordinatesProvider < handle
    
    properties (Access = private)
        I
        J
        K
    end
    
    methods
        function p = MockSpotCoordinatesProvider(I,J,K)
            p.I = I;
            p.J = J;
            p.K = K;
        end
        function [I, J, K] = getSpotCoordinates(p)
            I = p.I;
            J = p.J;
            K = p.K;
        end
        function num = getNumSpots(p)
            num = length(p.I);
        end
    end
    
end

