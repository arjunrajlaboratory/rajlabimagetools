function formattedString = formatStringsToTwoColumn(stringCellArray, extraSpaces)

    if nargin < 2
        extraSpaces = 2;
    end
    
    if isempty(stringCellArray)
        formattedString = '';
        return
    end
    
    lengths = cellfun(@length, stringCellArray);
    maxLength = max(lengths);
    fieldSize = maxLength + extraSpaces;
    formattingString = ['%-',num2str(fieldSize),'s'];
    formattingString = ['\t', formattingString, formattingString, '\n'];
    formattedString = sprintf(formattingString, stringCellArray{:});
    if mod(length(stringCellArray),2) == 1
        formattedString = [formattedString, sprintf('\n')];
    end
end

