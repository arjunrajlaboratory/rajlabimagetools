classdef ImageObjectDataFiles
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataFileNames;
        dataNums;
        dirPath;
    end
    
    methods
        function p = ImageObjectDataFiles(directory, filesToProcess)
            % Iterate on current directory if none specified.
            if nargin == 0
                directory = pwd;
            end
            if nargin < 2
                filesToProcess = [];
            end
            p.dirPath = directory;
            [dataFiles, p.dataNums] = getDataFiles(p.dirPath);
            [dataFiles, p.dataNums] = improc2.utils.subsetFiles(...
                dataFiles, p.dataNums, filesToProcess);
            p.dataFileNames = {dataFiles.name};
        end
    end
    
end

