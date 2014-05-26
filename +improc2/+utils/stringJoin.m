function joinedString = stringJoin(cellArray, delimiter)
    
    joinedString = '';
    for i = 1:length(cellArray)
        element = cellArray{i};
        joinedString = [joinedString, element];
        if i < length(cellArray)
            joinedString = [joinedString, delimiter];
        end
    end