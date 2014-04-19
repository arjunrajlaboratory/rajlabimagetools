%% getDataFiles
% RegEx enforced RajLab data file info retrieval from a specified directory 

%% Description
% Find the 'data***.mat' files in the provided directory and store
% their basic info as file structs from |dir()| and integers

%% Author
% Marshall J. Levesque 2012

function [dataFiles,dataNums] = getDataFiles(directoryPath)
    dataFiles = dir([directoryPath filesep 'data*.mat']);

    % Use regular expressions to enforce strict filename matching and also 
    % pull out file numbering from filenames for use later
    expr = ['data(\d{3})\.mat'];  % data%03d\.mat only
    dataNums = [];
    for k = 1:numel(dataFiles)
        [tokenStr] = regexp(dataFiles(k).name,expr,'tokens');
        if isempty(tokenStr)  % name doesn't match
            fprintf(1,'WARNING: Ignoring %s file\n',dataFiles(k).name);
            dataFiles(k) = [];
        else
            dataNums = [dataNums str2num(tokenStr{1}{1})];
        end
    end

