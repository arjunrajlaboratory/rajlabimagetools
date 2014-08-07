classdef ImageProvider < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filePaths
        numRows
        numCols
        currentCol
        currentRow
        chanIndex
        borderCheckH
        positionText
        contrastButtonDown
        
        imageSize
        
        currentImage
        rightImage
        downImage
        downRightImage
    end
    
    methods
        function p = ImageProvider(filePaths, borderCheckH, positionText)
            p.filePaths = filePaths;
            p.borderCheckH = borderCheckH;
            p.numRows = size(p.filePaths,1);
            p.numCols = size(p.filePaths,2);
            p.currentCol = 1;
            p.currentRow = 1;
            p.chanIndex = 1;
            p = p.loadImages();
            p.imageSize = size(p.currentImage);
            p.positionText = positionText;
            p.contrastButtonDown = false;
        end
        function p = moveToNextImageSet(p)
            p.currentCol = p.currentCol + 1;
            if p.currentCol + 1 > p.numCols
                p.currentCol = 1;
                p.currentRow = p.currentRow + 1;
                if p.currentRow + 1 > p.numRows
                    p.currentRow = 1;
                end
            end
            p = p.loadImages();
            p.positionText.setPosition(p.currentRow, p.currentCol);
        end
        function p = moveToPreviousImageSet(p)
            p.currentCol = p.currentCol - 1;
            if p.currentCol == 0
                p.currentCol = p.numCols - 1;
                p.currentRow = p.currentRow - 1;
                if p.currentRow == 0
                    p.currentRow = p.numRows - 1;
                end
            end
            p = p.loadImages();
            p.positionText.setPosition(p.currentRow, p.currentCol);
        end
        function p = moveToRandomImageSet(p)
            p.currentRow = ceil(rand * (p.numRows - 1));
            p.currentCol = ceil(rand * (p.numCols - 1));
            p = p.loadImages();
            p.positionText.setPosition(p.currentRow, p.currentCol);
        end
        function p = setChanIndex(p, chanIndex)
           p.chanIndex = chanIndex;
           p.loadImages();
        end
        function p = loadImages(p)
            p.currentImage = imread(cell2mat(p.filePaths(p.currentRow,...
                p.currentCol, p.chanIndex)));
            p.rightImage = imread(cell2mat(p.filePaths(p.currentRow,...
                p.currentCol+1, p.chanIndex)));
            p.downImage = imread(cell2mat(p.filePaths(p.currentRow+1,...
                p.currentCol, p.chanIndex)));
            p.downRightImage = imread(cell2mat(p.filePaths(p.currentRow+1,...
                p.currentCol+1, p.chanIndex))); 
        end
        function canvas = getCanvas(p, indexToLocMap, order)
            indexToImageMap = containers.Map([1,2,3,4],{p.currentImage,...
                   p.rightImage, p.downImage,...
                   p.downRightImage});
            canvas = zeros(p.imageSize(1) * 2, p.imageSize(2) * 2,size(p.currentImage,3));
            for indexLoc = numel(order):-1:1
                index = order(indexLoc);
                upperLeft = indexToLocMap(index);
                
                image = imadjust(indexToImageMap(index));
                if p.contrastButtonDown
                    image = image * 2;
                end
                if get(p.borderCheckH,'Value') == 1
                   image = p.addBorderToImage(image); 
                end
                
                rBegCanvas = max(1,upperLeft(1));
                cBegCanvas = max(1,upperLeft(2));
                rEndCanvas = min(upperLeft(1) + size(image,1) - 1, size(canvas,1));
                cEndCanvas = min(upperLeft(2) + size(image,2) - 1, size(canvas,2));
                if upperLeft(1) >= 1
                    rBegImage = 1;
                else
                    rBegImage = 2 + abs(upperLeft(1));
                end
                if upperLeft(2) >= 1
                    cBegImage = 1;
                else 
                    cBegImage = 2 + abs(upperLeft(2));
                end
                imagePiece = image(rBegImage:(rEndCanvas - rBegCanvas +...
                    rBegImage),cBegImage:(cEndCanvas - cBegCanvas + cBegImage),:);
                canvas(rBegCanvas:rEndCanvas,cBegCanvas:cEndCanvas,:) = imagePiece;
            end 
            canvas = uint16(canvas);
            display('hello');
        end
        function image = addBorderToImage(p,image)
            image(1:5,1:end) = inf;
            image(end-5:end,1:end) = inf;
            image(1:end,1:5) = inf;
            image(1:end,end-5:end) = inf;
        end
    end
    
end

