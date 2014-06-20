classdef ImageProvider < handle
    %UNTITLED13 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        standardImageSize
        numPixelOverlap
        currentTile
    end
    
    properties (SetAccess = private, GetAccess = private)
        imageDirectoryReader
    end
    
    properties (Dependent = true)
        availableFishChannels
        availableChannels
        Nrows
        Ncols
        scanDimensions
    end
    
    methods
        function p = ImageProvider(imageDirectoryReader, numPixelOverlap, startingTile)
            p.imageDirectoryReader = imageDirectoryReader;
            
            p.setStandardImageSize();
            p.numPixelOverlap = numPixelOverlap;
            
            if nargin < 3
                startingTile = dentist.utils.TilePosition(...
                    p.imageDirectoryReader.Nrows, p.imageDirectoryReader.Ncols);
            end
            p.goToTile(startingTile);
        end
        function TF = hasNeighbor(p, neighborDirection)
           TF = p.currentTile.hasNeighbor(neighborDirection); 
        end
        
        function goToTile(p, tile)
            assert((tile.Nrows == p.imageDirectoryReader.Nrows) && ...
                (tile.Ncols == p.imageDirectoryReader.Ncols), ...
                'tile dimensions are incompatible with image directory reader');
           p.currentTile = tile; 
        end
        
        function channels = get.availableFishChannels(p)
            channels = p.imageDirectoryReader.availableFishChannels;
        end
        function scanDimensions = get.scanDimensions(p)
            row_width = p.standardImageSize(1) * p.Nrows - (p.numPixelOverlap * (p.Nrows - 1));
            col_width = p.standardImageSize(2) * p.Ncols - (p.numPixelOverlap * (p.Ncols - 1));
            scanDimensions = [row_width, col_width];
        end
        
        function channels = get.availableChannels(p)
           channels = p.imageDirectoryReader.availableChannels; 
        end
        
        function num = get.Nrows(p)
            num = p.imageDirectoryReader.Nrows;
        end
        
        function num = get.Ncols(p)
            num = p.imageDirectoryReader.Ncols;
        end
        
        function img = getExtendedDapiImage(p)
            currentImg = p.getImageByChannelByTile(...
                'dapi', p.currentTile); 
            [downImg, downWasFound] = p.getNeighborImageForExtension('down', 'dapi');
            [rightImg, rightWasFound] = p.getNeighborImageForExtension('right', 'dapi');
            [downRightImg, downRightWasFound] = p.getNeighborImageForExtension('down-right', 'dapi');
            
            if downRightWasFound && (~ downWasFound || ~ rightWasFound)
                % Happens if one of down or right was a bad image, but
                % down-right exists and is not.
                % Discard the downRightImg because user of this method
                % expects a rectangular image.
                downRightImg = [];
            elseif (downWasFound && rightWasFound) && ~downRightWasFound
                % Happens if down-right is a bad image but neither the down
                % or the right were bad. Arbitrarily discard the down image
                % too so that the final output can be rectangular.
                downImg = [];
            end
            
            img = [currentImg, rightImg; downImg, downRightImg];
        end
        
        function img = getImageFromChannel(p, channelName)
            img = p.getImageByChannelByTile(channelName, p.currentTile);
        end
        
    end
    
    methods (Access = private)
        
        function setStandardImageSize(p)
            channelName = p.availableChannels{1};
            filePath = p.imageDirectoryReader.getFilePathByChannelByPosition(...
                channelName,1,1);
            img = imread(filePath);
            p.standardImageSize = size(img);
        end
        
        function [img, imgWasFound] = getNeighborImageForExtension(p, neighborDirection, channelName)
            if p.currentTile.hasNeighbor(neighborDirection)
                try
                    img = p.getImageByChannelByTile(...
                        channelName, p.currentTile.getNeighbor(neighborDirection));
                    imgWasFound = true;
                    if ismember(neighborDirection, {'down', 'down-right'})
                        % 1:k returns sequence in steps of 1 up to at most
                        % k. This means k does not have to be an integer.
                        % That's why this works even if size is not even.
                        img = img(1 : floor(size(img, 1) / 2), :);
                    end                    
                    if ismember(neighborDirection, {'right', 'down-right'})
                        img = img(:, 1 : floor(size(img, 2) / 2));
                    end
                    
                catch err
                    if strcmp(err.identifier, 'dentist:BadImage')
                        img = [];
                        imgWasFound = false;
                        return;
                    else
                        rethrow(err);
                    end
                end
            else
                img = [];
                imgWasFound = false;
            end
        end
        
        function img = getImageByChannelByTile(p, channelName, tile)
            filePath = p.imageDirectoryReader.getFilePathByChannelByPosition(...
                channelName, tile);
            fprintf('reading image %s...\n', filePath) 
            img = imread(filePath);
            if ~all(size(img) == p.standardImageSize)
                size(img)
                % Due to some glitch, the microscope will occasionally produce an image
                % that is completely the wrong size. These images cannot be
                % used for analysis.
                error('dentist:BadImage', 'Image at %s has inconsistent dimensions', filePath);
            end
            % Crop out the pixel overlap
            if tile.hasNeighbor('down')
                img = p.deleteImageOverlapBottom(img);
            end
            if tile.hasNeighbor('right')
                img = p.deleteImageOverlapRight(img);
            end
        end
        
        function out = deleteImageOverlapRight(p, inputImg)
            out = inputImg(:,1:size(inputImg,2) - p.numPixelOverlap);
        end
        function out = deleteImageOverlapBottom(p, inputImg)
            out = inputImg(1:size(inputImg,1) - p.numPixelOverlap,:);
        end
    end
    
end

