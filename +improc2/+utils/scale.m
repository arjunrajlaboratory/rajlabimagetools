function [img, minAndMaxSaturationValues] = scale(img, minAndMaxSaturationValues)
    
    if nargin < 2
        minAndMaxSaturationValues = [];
    end
    
    if ~isempty(minAndMaxSaturationValues) && ...
            (~issorted(minAndMaxSaturationValues) || numel(minAndMaxSaturationValues) ~= 2)
        error('Scale definition must be in the form: [minIntensity maxIntensity]');
    end
    
    if ~isa(img,'double')
        img = single(img);
    end
    
    if isempty(minAndMaxSaturationValues)
        minAndMaxSaturationValues = [min(img(:)), max(img(:))];
    end 
    
    minAndMaxSaturationValues = double(minAndMaxSaturationValues);
    
    minSatVal = minAndMaxSaturationValues(1);
    maxSatVal = minAndMaxSaturationValues(2);
    
    img = (img - minSatVal) / (maxSatVal - minSatVal);
    img = min(img, 1);
    img = max(img, 0);
    
end

