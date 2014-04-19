%% ImageObjectFullStkProvider < ImgProvider
%   An implementation of ImgProvider for storing the full image stack
%   corresponding to a particular channel in an image_object. 
%

%% Public Methods:
% * ImageObjectFullStkProvider(dirPath) 
%   Constructor. Optionally takes in a directory name which will be the
%   first place the stack provider will go to look for images related to an
%   image object.
% * loadImage(obj, channelName)
%   Makes a request to store the image stack pertaining to the input
%   image_object for given channel. If the full path to the stack specified
%   within the obj somehow doesn't lead to a loadable image, the method
%   will attempt to load a file with the same filename within the current
%   directory.
% * changeDirPath(dirPath)
%   Changes the first-preference directory in which to search for images to
%   the input dirPath.
%% Public Properties:
% * img
%   The stack data stored
% * imgId
%   The path to the image stack using the path data stored in obj.

classdef ImageObjectFullStkProvider < improc2.ImgProvider
    
    properties
        dirPath;   % An optional explicit path in which to look for images.
    end
    
    properties (SetAccess = 'private', GetAccess = 'private')
        numLoadAttempts = 0;
        attemptedStkPaths = {};
    end
    
    methods (Access = protected)
        
        function stkPath = stkPathConstructor(p,objH,channelName)
            stkPath = [objH.getImageDirPath, filesep, ...
                objH.getImageFileName(channelName)];
        end
        
        function imgIdOut = findImgId(p, objH, channelName)
            imgIdOut = p.stkPathConstructor(objH,channelName);
        end
        
        function imgStk = loadWithoutDirPath(p, objH, channelName)
            try
                stkPath = p.stkPathConstructor( objH, channelName);
                imgStk = p.attemptLoad(stkPath);
            catch
                try
                    stkPath = objH.getImageFileName(channelName);
                    imgStk = p.attemptLoad(stkPath);
                catch
                    p.loadFail(channelName);
                end
            end
        end
        
        function imgStk = attemptLoad(p, stkPath)
            p.numLoadAttempts = p.numLoadAttempts + 1;
            p.attemptedStkPaths{p.numLoadAttempts} = stkPath;
            imgStk = readmm(stkPath);
            fprintf(1,['\tLoaded: ' stkPath '\n']);
        end
            
        function imgStk = loadWithDirPath(p, objH, channelName)
            try
                stkPath = [p.dirPath, filesep, objH.getImageFileName(channelName)];
                imgStk = p.attemptLoad(stkPath);
            catch
                imgStk = p.loadWithoutDirPath(objH, channelName);
            end
        end

        function loadFail(p, channelName)
           msg = '\t!! Failed to load Image!\n';
           msg = [msg '\t!! Attempted to find image in these locations:\n'];
           for j = 1:p.numLoadAttempts
               msg = [msg '\t' p.attemptedStkPaths{j} '\n'];
           end
           fprintf(1, msg);
           error('Could not load image for %s', channelName);
        end
        
        function p = loadNewImage(p, objH, channelName)            
            fprintf(1,['\tLoading ' channelName ' image data ...\n']);
            
            p.numLoadAttempts = 0;
            p.attemptedStkPaths = {};
            
            if isempty(p.dirPath)
                imgStk = p.loadWithoutDirPath(objH, channelName);
            else
                imgStk = p.loadWithDirPath(objH, channelName);
            end
            p.img = imgStk.imagedata;
            
        end
    end
    
    methods
        function p = ImageObjectFullStkProvider(dirPath)
            if nargin > 0
                p.dirPath = dirPath;
            else
                p.dirPath = [];
            end
        end
        
        function p = changeDirPath(p, dirPath)
            p.dirPath = dirPath;
        end
        
        function img = getImage(p, objH, channelName)
            p.loadImage(objH, channelName);
            img = p.img;
        end
    end
    
end

