classdef FileBasedImageObjectArrayCollection < improc2.interfaces.ObjectArrayCollection
    
    properties (SetAccess = private, GetAccess = private)
        imageObjectDataFiles
    end
    
    methods
        function p = FileBasedImageObjectArrayCollection(...
                imageObjectDataFiles, varargin)
            p.imageObjectDataFiles = imageObjectDataFiles;
        end
        
        function objects = getObjectsArray(p, n)
            fileToLoad = p.getDataFileFullPath(n);
            fprintf(1,'\tReading data file: %s\n',fileToLoad);
            loadedData = load(fileToLoad);
            objects = loadedData.objects;
        end
        
        function setObjectsArray(p, objects, n)
            fileToSave = p.getDataFileFullPath(n);
            fprintf(1,'\tSaving data file: %s\n',fileToSave);
            save(fileToSave, 'objects');
        end
        
        function len = length(p)
            len = length(p.imageObjectDataFiles.dataFileNames);
        end
    end
    
    methods (Access = private)
        function fullpath = getDataFileFullPath(p, n)
            fullpath = [p.imageObjectDataFiles.dirPath filesep ...
                p.imageObjectDataFiles.dataFileNames{n}];
        end
    end
end

