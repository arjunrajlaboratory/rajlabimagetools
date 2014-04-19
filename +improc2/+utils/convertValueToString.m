function valueAsString = convertValueToString(itemValue, itemClassName)
    switch itemClassName
        case 'improc2.TypeCheckedLogical'
            if itemValue == true
                valueAsString = 'true';
            else
                valueAsString = 'false';
            end
        case {'improc2.TypeCheckedFactor', 'improc2.TypeCheckedYesNoOrNA'}
            valueAsString = itemValue;
        case 'improc2.TypeCheckedNumeric'
            valueAsString = num2str(itemValue);
        case 'improc2.TypeCheckedString'
            valueAsString = itemValue;
        otherwise
            error(['can only convert values derived from type-checked' ...
                'logical, factor, YesNoOrNA, numeric or string'])
    end
    
end

