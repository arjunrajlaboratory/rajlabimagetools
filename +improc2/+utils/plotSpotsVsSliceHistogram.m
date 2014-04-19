function [hincluded, hexcluded, xCoordsStruct, yCoordsStruct] = plotSpotsVsSliceHistogram(regionalMaxProcData, varargin)
    
    [~, ~, Ks] = getSpotCoordinatesIncludingExcludedSlices(regionalMaxProcData);
    
    if ~isempty(Ks)
        tabKs = tabulate(Ks);
        tabKs = tabKs(:,1:2);
    else
        tabKs = [1 0];
    end
    
    [Kvals, Kfreqs] = paddedIntegerTable(tabKs, regionalMaxProcData.imageSize(3));
    
    [xCoordsAll, yCoordsAll] = coordsForHorizontalHistogram(Kvals', Kfreqs');
    
    includedSlicesColor = [0, 0, 1];
    excludedSlicesColor = [0.8, 0.8, 0.8];
    
    excludedSlices = regionalMaxProcData.excludedSlices;
    
    inIncluded = find(~ismember(Kvals, excludedSlices));
    inExcluded = find(ismember(Kvals, excludedSlices));
    
    xCoordsIncluded = xCoordsAll(:, inIncluded);
    yCoordsIncluded = yCoordsAll(:, inIncluded);
    
    xCoordsExcluded = xCoordsAll(:, inExcluded);
    yCoordsExcluded = yCoordsAll(:, inExcluded);
    
    hincluded = patch(xCoordsIncluded, yCoordsIncluded, 'k', varargin{:});
    set(hincluded, 'FaceColor', includedSlicesColor)
    set(hincluded, 'HitTest', 'off')
    hexcluded = patch(xCoordsExcluded, yCoordsExcluded, 'k', varargin{:});
    set(hexcluded, 'FaceColor', excludedSlicesColor)
    set(hexcluded, 'HitTest', 'off')
    
    xCoordsStruct = struct();
    yCoordsStruct = struct();
    xCoordsStruct.included = xCoordsIncluded;
    yCoordsStruct.included = yCoordsIncluded;
    xCoordsStruct.excluded = xCoordsExcluded;
    yCoordsStruct.excluded = yCoordsExcluded;
    
end

function [values, frequencies] = paddedIntegerTable(inputTable, maxValueNecessary)
    values = inputTable(:,1);
    frequencies = inputTable(:,2);
    zerosToAdd = maxValueNecessary - values(end);
    frequencies = [frequencies; zeros(zerosToAdd, 1)];
    values = (values(1):maxValueNecessary)';
end

function [xCoords, yCoords] = coordsForHorizontalHistogram(...
        rowOfIntegerValues, rowOfFrequencies)
   
    N = length(rowOfFrequencies);
    
    xCoords = [zeros(1, N); zeros(1, N); rowOfFrequencies; rowOfFrequencies];
    
    colWidth = 0.8;
    yCoords = colWidth/2 * [-ones(1,N); ones(1,N); ones(1,N); -ones(1,N)];
    yCoords = yCoords + repmat(rowOfIntegerValues, 4, 1);
end