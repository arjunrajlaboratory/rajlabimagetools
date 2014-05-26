function choicesAsString = convertChoicesToString(itemChoices, itemClassName)
    switch itemClassName
        case 'improc2.TypeCheckedLogical'
            choicesAsString = 'logical true or false';
        case {'improc2.TypeCheckedFactor', 'improc2.TypeCheckedYesNoOrNA'}
            choicesAsString = improc2.utils.stringJoin(itemChoices, ', ');
        case 'improc2.TypeCheckedNumeric'
            choicesAsString = itemChoices;
        case 'improc2.TypeCheckedString'
            choicesAsString = itemChoices;
        otherwise
            error(['can only convert choices derived from type-checked' ...
                'logical, factor, YesNoOrNA, numeric or string'])
    end
    
end
