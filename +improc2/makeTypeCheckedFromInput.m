function p = makeTypeCheckedFromInput( input )
    
    if islogical(input) && isscalar(input)
        p = improc2.TypeCheckedLogical(input);
    elseif ischar(input)
        p = improc2.TypeCheckedString(input);
    elseif isnumeric(input) && isscalar(input)
        p = improc2.TypeCheckedNumeric(input);
    elseif iscell(input) && all(cellfun(@ischar, input))
        p = improc2.TypeCheckedFactor(input);
    elseif isnumeric(input) && ~isscalar(input)
        p = improc2.TypeCheckedNumericNonScalar(input);
    else
        error('improc2:ConvertToTypeCheckedFailed', ...
            ['Can only make type checked values from\n', ...
            'scalar logical, scalar number, nonscalar number, string, or cell array of strings'])
    end
end

