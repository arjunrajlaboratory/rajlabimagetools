classdef ReadOnlyFileBasedImageObjectArrayCollection < ...
        improc2.utils.FileBasedImageObjectArrayCollection
    
    properties
    end
    
    methods
        function p = ReadOnlyFileBasedImageObjectArrayCollection(varargin)
            p = p@improc2.utils.FileBasedImageObjectArrayCollection(varargin{:});
        end
        %override
        function setObjectsArray(p, varargin)
            fprintf(1,'\tIgnoring save request: operating in read only mode\n')
        end
    end
    
end

