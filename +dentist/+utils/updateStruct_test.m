x = struct('param', 0, 'type', 3);

y = struct('param', 1);

z = dentist.utils.updateStruct(x, y);
assert(z.param == 1)
assert(z.type == 3)
assert(length(fields(z)) == length(fields(x)));

y2 = struct('Type', 2); 
try 
    z2 = dentist.utils.updateStruct(x, y2); %should fail due to misspelling in y2.
    error('Expected an error to be thrown');
catch err
    if strcmp(err.message, 'Expected an error to be thrown')
        rethrow(err)
    else
        fprintf('Error generated as expected\n')
    end
end
