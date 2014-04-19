function [dataFiles, dataNums] = subsetFiles(dataFiles, dataNums, dataNumsToSelect)

if ~isempty(dataNumsToSelect)  % User specified a subset of files to process
    [matchingNums, matchingInds] = intersect(dataNums, dataNumsToSelect);
    if isempty(matchingNums) || numel(matchingNums) ~= numel(dataNumsToSelect)
        msg = 'Specified file numbers do not match the found data files\n';
        msg = [msg 'Found data files:\t' sprintf('%d ',dataNums) '\n'];
        msg = [msg 'Specified data files:\t' sprintf('%d ',dataNumsToSelect)];
        error('improc2:SomeToSelectNotFound', msg);
    else
        dataFiles = dataFiles(matchingInds);
        dataNums = dataNums(matchingInds);
    end
end
end
