%% ImgProvider (Abstract)
%   Provides a container that stores an image based on input and avoids
%   reloading data if the next request turns out to be for the same image.
%
%% Public Methods Defined Here:
% * loadImage(varargin)
%   A client makes a request that an image be loaded into the container.
%   The class calculates an image Identifier (such as the path to the image
%   file) based on the inputs, and compares it to the Identifier 
%   of the image already within
%   the container. If they differ (default is string comparison of the ids), 
%   the new image is loaded and stored.
%   Otherwise, the original image is kept. 
%
%% Public Properties:
% * img
%   The image stored in the container
% * imgId
%   The unique identifier describing the image being stored.
%
%% Methods to Define in Subclasses:
% * findImgId(varargin) -> imgId
%   Should calculate an image Id using the inputs given to *loadImage()*
% * loadNewImage(varargin)
%   Should load the image specified by the inputs given to *loadImage()*
%   into the container.
%
%% Implementation Details:
%
%   The class derives from handle, and is therefore a pass-by-reference
%   class that is only constructed once - when the constructor is
%   explicitly called. 

classdef (Abstract) ImgProvider < handle
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = 'public', SetAccess = 'protected')
        img = [];
        imgId = []; % A unique identifier of an img to prevent reloading.
    end
    
    methods (Abstract = true, Access = protected)
        p = loadNewImage(p, varargin);
        imgIdOut = findImgId(p, varargin);
    end
    
    methods (Access = protected)
        
        function TF = idsAreEqual(p,id1,id2)
            TF = strcmp(id1,id2);
        end
        
    end
    
    methods
        function p = ImgProvider
        end
        
        function p = loadImage(p, varargin)
            requestedImgStkId = p.findImgId(varargin{:});
            if ~p.idsAreEqual(p.imgId, requestedImgStkId)
                p.loadNewImage(varargin{:});
                p.imgId = requestedImgStkId;
            end
        end
        
    end
    
end

