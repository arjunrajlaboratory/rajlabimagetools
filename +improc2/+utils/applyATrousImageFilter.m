function filteredImg = applyATrousImageFilter(img, filterParams)
    
    [aTrous, ~] = aTrousWaveletTransform(img, 'numLevels', filterParams.numLevels,...
        'sigma', filterParams.sigma);
    
    if ndims(img) == 3 
        filteredImg = sum(aTrous,4);
    else               
        filteredImg = sum(aTrous,3);
    end
    
end

