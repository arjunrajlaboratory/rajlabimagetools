function outim = blowUpPixels(im, desiredWidthOfBlownUpPixel, ...
        prioritizeLowOrHigh, maskOfAreasWithPixels)
    
    if nargin < 4
        maskOfAreasWithPixels = (im > 0);
    end
    
    assert(all(isfinite(im(:))), 'Image cannot contain infinite values')
    assert(all(im(:) >= 0), 'Image must be nonnegative')
    assert(ismember(prioritizeLowOrHigh, {'low', 'high'}), ...
        'third input must be low or high')
    assert(mod(desiredWidthOfBlownUpPixel,1) == 0, 'width should be an integer')
    assert(desiredWidthOfBlownUpPixel >= 1, 'width should be at least 1')
    
    
    neighborhood = ones(desiredWidthOfBlownUpPixel);
    
    
    switch prioritizeLowOrHigh
        case 'high'
            imToDilate = im;
        case 'low'
            imToDilate = -im;
    end
    
    imToDilate(~ maskOfAreasWithPixels) = -Inf;
    outim = imdilate(imToDilate, neighborhood);
    
    outim(~isfinite(outim)) = 0;
    if strcmp(prioritizeLowOrHigh, 'low')
        outim = -outim;
    end
end

