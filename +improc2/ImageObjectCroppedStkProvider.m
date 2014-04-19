%% ImageObjectCroppedStkProvider
%   Provides cropped stacks for classic image objects. Avoids reloading
%   whole stacks if the next object requested belongs to the same stack as
%   the previous, as determined by ImageObjectFullStkProvider.
%
%   Despite its naming, it does NOT Inherit from ImgProvider 
%% Intended Use:
%
% % objects is an image_object array derived from one scope position.
% StkProvider = improc2.ImageObjectFullStkProvider;
%
% StkProvider.loadImage(objects(1), 'cy');   %loads cy image, and crops
%
% doSomethingWith( StkProvider.croppedimg );
%
% StkProvider.loadImage(objects(1), 'tmr');  %loads tmr image, and crops
%
% StkProvider.loadImage(objects(2), 'tmr');  %does not reload the full tmr image
%                                            But crops to new object.
% StkProvider.delete(); % If not deleted, the last stack may persist.
%
%% Public Methods:
% * ImageObjectCroppedStkProvider(dirPath) 
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
% * croppedimg
%   The cropped image stack for the requested obj and channel.

classdef ImageObjectCroppedStkProvider < handle
    
    properties (GetAccess = 'public', SetAccess = 'protected')
        croppedimg = [];
    end
    
    properties (GetAccess = 'protected', SetAccess = 'protected')
        FullStkProvider = [];
    end
    
    methods
        function p = ImageObjectCroppedStkProvider(varargin)
            p.FullStkProvider = improc2.ImageObjectFullStkProvider(varargin{:});
        end
        
        function changeDirPath(p, dirPath)
            p.FullStkProvider = p.FullStkProvider.changeDirPath(dirPath);
        end
        
        function loadImage(p, objH, channelName)
            p.FullStkProvider.loadImage(objH, channelName);
            p.croppedimg = improc2.utils.cropImageToObjBoundingBox(...
                p.FullStkProvider.img, objH);
        end
        
        function img = getImage(p, objH, channelName)
            p.loadImage(objH, channelName);
            img = p.croppedimg;
        end
        
    end
    
end

