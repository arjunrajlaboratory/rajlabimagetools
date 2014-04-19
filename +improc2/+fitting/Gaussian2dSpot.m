classdef Gaussian2dSpot
    
    properties
        xCenter = NaN;
        yCenter = NaN;
        sigma = NaN;
        amplitude = NaN;
        zPlane = 1;
    end
    
    methods
        function spot = Gaussian2dSpot(xCenter, yCenter, sigma, amplitude, zPlane)
            if nargin == 0
                return;
            end
            if nargin == 5
                spot.zPlane = zPlane;
            end
            spot.xCenter = xCenter;
            spot.yCenter = yCenter;
            spot.sigma = sigma;
            spot.amplitude = amplitude;
        end
        
        function intensity = valueAt(spot, x, y, zPlaneScalar)
            if nargin == 4 && (zPlaneScalar ~= spot.zPlane)
                intensity = zeros(size(x));
                return
            end
            coefficients = [spot.amplitude, 0, 1/spot.sigma, spot.xCenter, spot.yCenter];
            xAndY = [x(:), y(:)];
            intensity = gaussian2dfunc(coefficients, xAndY);
            intensity = reshape(intensity, size(x));
        end
    end
end

