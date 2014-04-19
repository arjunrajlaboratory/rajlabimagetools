function updatedStruct = updateStruct(existingStruct, updatingStruct)

    assert(all(ismember(fields(updatingStruct), fields(existingStruct))), ...
        'updatingStruct has a field not found in exitingStruct');
    
    updatedStruct = existingStruct;
    fieldNames = fields(existingStruct);
    for i = 1:length(fieldNames)
        fieldName = fieldNames{i};
        if isfield(updatingStruct, fieldName)
            updatedStruct.(fieldName) = updatingStruct.(fieldName);
        end
    end
end

