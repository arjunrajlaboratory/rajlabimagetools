function spots = makeGaussianSpotVector(Xs, Ys, sigmas, amplitudes, Zs)
    
    numSpots = max([length(Xs), length(Ys), length(amplitudes), ...
        length(sigmas), length(Zs)]);
    
    if numSpots > 1
        if isscalar(Xs)
            Xs = Xs * ones(1, numSpots);
        end
        if isscalar(Ys)
            Ys = Ys * ones(1, numSpots);
        end
        if isscalar(sigmas)
            sigmas = sigmas * ones(1, numSpots);
        end
        if isscalar(amplitudes)
            amplitudes = amplitudes *ones(1,numSpots);
        end
        if isscalar(Zs)
            Zs = Zs * ones(1, numSpots);
        end
    end
    
    spots(numSpots) = improc2.fitting.Gaussian2dSpot();
    
    for i = 1:numSpots
        spots(i) = improc2.fitting.Gaussian2dSpot(Xs(i), Ys(i),...
            sigmas(i), amplitudes(i), Zs(i));
    end
end

