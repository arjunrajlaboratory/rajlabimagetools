% Generate canvases for tile-postion with UL of [r, c]
function canvases = generateCanvases(r, c, filePaths, imageSize,...
    tileSize, grid)
    canvases = cell(1,size(filePaths,3));
    for index = 1:size(filePaths,3)
        if numel(imageSize) == 2
            canvasSize = tileSize;
        else
            canvasSize = [tileSize,3];
        end
        canvases{1,index} = zeros(canvasSize);
    end
    gridMaskR = grid(:,:,1) >= r & grid(:,:,1) <= r + tileSize(1);
    gridMaskC = grid(:,:,2) >= c & grid(:,:,2) <= c + tileSize(2);
    gridMask = gridMaskR & gridMaskC;
    
    for gridIndex = find(gridMask)'
        [rInd,cInd] = ind2sub(size(gridMask),gridIndex);
        
        topL = grid(rInd, cInd,:);
        topR = [topL(1),topL(2) + imageSize(2) - 1];
        botL = [topL(1) + imageSize(1) - 1,topL(2)];
        
        rBegC = max(topL(1) - r + 1,1);
        rEndC = min(tileSize(1),botL(1) - r + 1);
        cBegC = max(topL(2) - c + 1,1);
        cEndC = min(tileSize(2),topR(2) - c + 1);
        
        rBegI = max(r - topL(1) + 1,1);
        rEndI = min(imageSize(1),(r + tileSize(1) - 1) - topL(1) + 1);
        cBegI = max(c - topL(2) + 1,1);
        cEndI = min(imageSize(2),(c + tileSize(2) - 1) - topL(2) + 1);
        
        for index = 1:size(filePaths,3)
            img = imread(filePaths{rInd, cInd, index});
            canvas = canvases{1,index};
            canvas(rBegC:rEndC,cBegC:cEndC,:) = img(rBegI:rEndI,cBegI:cEndI,:);
            canvases{1,index} = uint8(canvas);
        end
    end
end