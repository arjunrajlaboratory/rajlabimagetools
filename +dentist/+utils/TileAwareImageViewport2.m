classdef TileAwareImageViewport2 < dentist.utils.ImageViewport2
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public, GetAccess = public)
        Nrows
        Ncols
        standardImageWidth
        standardImageHeight
        numPixelOverlap
    end
    
    methods
        function p = TileAwareImageViewport2(objectWithTilingInfo)
            [imageWidth, imageHeight] = dentist.utils.computeTiledImageWidthAndHeight(objectWithTilingInfo);
            p = p@dentist.utils.ImageViewport2(imageWidth, imageHeight);
            p.Nrows = objectWithTilingInfo.Nrows;
            p.Ncols = objectWithTilingInfo.Ncols;
            p.standardImageWidth = objectWithTilingInfo.standardImageSize(2);
            p.standardImageHeight = objectWithTilingInfo.standardImageSize(1);
            p.numPixelOverlap = objectWithTilingInfo.numPixelOverlap;
        end
        
        function tile = findTileAtCenter(p)
            tile = p.findTileAtPoint(p.centerXPosition, p.centerYPosition);
        end
         
        function TF = containsTile(p, tile)
            [xLow, xHigh, yLow, yHigh] = ...
                dentist.utils.findIndicesOfTileInTilingImage(tile, ...
                p.standardImageWidth, p.standardImageHeight, p.numPixelOverlap);
            corners = [xLow yLow; xLow yHigh; xHigh yHigh; xHigh yLow];
            viewportCorners = [0 0; p.width-1 0; p.width-1 p.height-1; 0 p.height-1];
            viewportCorners(:,1) = p.ulCornerXPosition + viewportCorners(:,1);
            viewportCorners(:,2) = p.ulCornerYPosition + viewportCorners(:,2);
            % if they overlap the viewport contains a corner of the tile or the tile
            % must contain a corner of the viewport
            TF = any(p.contains(corners(:,1), corners(:,2))) || ...
                any((viewportCorners(:,1) >= xLow) & ...
                (viewportCorners(:,1) <= xHigh) & (viewportCorners(:,2) >= yLow) & ...
                (viewportCorners(:,2) <= yHigh));
        end
        
        function img = getCroppedImage(p, imageProvider, channelName)
            if nargin < 3
                img = p.getCroppedImage@dentist.utils.ImageViewport(imageProvider);
                return;
            end 
            tile = p.findTileAtPoint(p.ulCornerXPosition, p.ulCornerYPosition);
            tileAtRowStart = tile;
            onFirstTile = true;
            while true
                imageProvider.goToTile(tile);
                tileImg = imageProvider.getImageFromChannel(channelName);
                if onFirstTile
                    img = zeros(p.height, p.width, class(tileImg));
                    onFirstTile = false;
                end
                [tileCoords, viewCoords] = p.coordsOfOverlapWithTile(tile);
                
                if size(viewCoords(3):viewCoords(4), 2) == size(tileCoords(3):tileCoords(4), 2) && size(viewCoords(1):viewCoords(2), 2) == size(tileCoords(1):tileCoords(2), 2)
                    img(viewCoords(3):viewCoords(4), viewCoords(1):viewCoords(2)) = ...
                        tileImg(tileCoords(3):tileCoords(4), tileCoords(1):tileCoords(2));
                elseif size(viewCoords(3):viewCoords(4), 2) ~= size(tileCoords(3):tileCoords(4), 2) && size(viewCoords(1):viewCoords(2), 2) ~= size(tileCoords(1):tileCoords(2), 2)
                    tileSize.y = size(tileCoords(3):tileCoords(4), 2);
                    tileSize.x = size(tileCoords(1):tileCoords(2), 2);
                    img(viewCoords(3):(viewCoords(3) + tileSize.y - 1), viewCoords(1):(viewCoords(1) + tileSize.x - 1)) = ...
                        tileImg(tileCoords(3):tileCoords(4), tileCoords(1):tileCoords(2));
                elseif size(viewCoords(3):viewCoords(4), 2) ~= size(tileCoords(3):tileCoords(4), 2) && size(viewCoords(1):viewCoords(2), 2) == size(tileCoords(1):tileCoords(2), 2)
                    tileSize.y = size(tileCoords(3):tileCoords(4), 2);  
                    img(viewCoords(3):(viewCoords(3) + tileSize.y - 1), viewCoords(1):viewCoords(2)) = ...
                        tileImg(tileCoords(3):tileCoords(4), tileCoords(1):tileCoords(2));
                elseif size(viewCoords(3):viewCoords(4), 2) == size(tileCoords(3):tileCoords(4), 2) && size(viewCoords(1):viewCoords(2), 2) ~= size(tileCoords(1):tileCoords(2), 2)
                    tileSize.x = size(tileCoords(1):tileCoords(2), 2);  
                    img(viewCoords(3):viewCoords(4), viewCoords(1):(viewCoords(1) + tileSize.x - 1)) = ...
                        tileImg(tileCoords(3):tileCoords(4), tileCoords(1):tileCoords(2));
                end
                
                if tile.hasNeighbor('right') && p.containsTile(tile.getNeighbor('right'))
                    tile = tile.getNeighbor('right');
                elseif tileAtRowStart.hasNeighbor('down') && p.containsTile(tileAtRowStart.getNeighbor('down'))
                    tileAtRowStart = tileAtRowStart.getNeighbor('down');
                    tile = tileAtRowStart;
                else
                    break;
                end
            end 
        end
                 
%     end
%     
%     methods (Access = private)
        function [coordsInTile, coordsInView, coordsInImage] = coordsOfOverlapWithTile(p, tile)
            [xLow, xHigh, yLow, yHigh] = ...
                dentist.utils.findIndicesOfTileInTilingImage(tile, ...
                p.standardImageWidth, p.standardImageHeight, p.numPixelOverlap);
            xLowOverlapping = max(p.ulCornerXPosition, xLow);
            xHighOverlapping = min(p.ulCornerXPosition + p.width - 1, xHigh);
            yLowOverlapping = max(p.ulCornerYPosition, yLow);
            yHighOverlapping = min(p.ulCornerYPosition + p.height - 1, yHigh);
            coordsInImage = [xLowOverlapping, xHighOverlapping, ...
                                yLowOverlapping, yHighOverlapping];
            coordsInTile = [coordsInImage(1:2) - xLow + 1, ...
                                coordsInImage(3:4) - yLow + 1];
            coordsInView = [coordsInImage(1:2) - p.ulCornerXPosition + 1, ...
                                coordsInImage(3:4) - p.ulCornerYPosition + 1];
        end
        
        function tile = findTileAtPoint(p, x, y)
            scaledX = (x - 1)/(p.standardImageWidth - p.numPixelOverlap);
            col = min(floor(scaledX) + 1, p.Ncols);
            scaledY = (y - 1)/(p.standardImageHeight - p.numPixelOverlap);
            row = min(floor(scaledY) + 1, p.Nrows);
            tile = dentist.utils.TilePosition(p.Nrows, p.Ncols, row, col);
        end
    end
    
end

