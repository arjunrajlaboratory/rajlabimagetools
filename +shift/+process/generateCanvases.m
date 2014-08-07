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
    
    % Is Upper-Left corner contained in the bounding box
    gridMaskR1 = grid(:,:,1) >= r & grid(:,:,1) <= r + tileSize(1);
    gridMaskC1 = grid(:,:,2) >= c & grid(:,:,2) <= c + tileSize(2);
    gridMask1 = gridMaskR1 & gridMaskC1;
    % Is Upper-Right corner contained in the bounding box
    gridMaskR2 = grid(:,:,1) >= r & grid(:,:,1) <= r + tileSize(1);  
    gridMaskC2 = grid(:,:,2) + imageSize(2) >= c & grid(:,:,2) + imageSize(2) <= c + tileSize(2);
    gridMask2 = gridMaskR2 & gridMaskC2;
    % Is Down-Left corner contained in the bounding box
    gridMaskR3 = grid(:,:,1) + imageSize(1) >= r & grid(:,:,1) + imageSize(1) <= r + tileSize(1);  
    gridMaskC3 = grid(:,:,2) >= c & grid(:,:,2) <= c + tileSize(2);
    gridMask3 = gridMaskR3 & gridMaskC3;
    % Is Down-Right corner contained in the bounding box
    gridMaskR4 = grid(:,:,1) + imageSize(1) >= r & grid(:,:,1) + imageSize(1) <= r + tileSize(1);  
    gridMaskC4 = grid(:,:,2) + imageSize(2) >= c & grid(:,:,2) + imageSize(2) <= c + tileSize(2);
    gridMask4 = gridMaskR4 & gridMaskC4;
    
    % Is Upper-Left of bounding box contained in image
    gridMaskR5 = r >= grid(:,:,1) & r <= grid(:,:,1) + tileSize(1);
    gridMaskC5 = c >= grid(:,:,2) & c <= grid(:,:,2) + tileSize(2);
    gridMask5 = gridMaskR5 & gridMaskC5;
    % Is Upper-Right of bounding box contained in image
    gridMaskR6 = r >= grid(:,:,1) & r <= grid(:,:,1) + tileSize(1);
    gridMaskC6 = c + imageSize(2) >= grid(:,:,2) & c + imageSize(2) <= grid(:,:,2) + tileSize(2);
    gridMask6 = gridMaskR6 & gridMaskC6;
    % Is Down-Left of bounding box contained in image
    gridMaskR7 = r +  imageSize(1) >= grid(:,:,1) & r + imageSize(1) <= grid(:,:,1) + tileSize(1);
    gridMaskC7 = c >= grid(:,:,2) & c <= grid(:,:,2) + tileSize(2);
    gridMask7 = gridMaskR7 & gridMaskC7;
    % Is Down-Right of bounding box contained in image
    gridMaskR8 = r +  imageSize(1) >= grid(:,:,1) & r + imageSize(1) <= grid(:,:,1) + tileSize(1);
    gridMaskC8 = c + imageSize(2) >= grid(:,:,2) & c + imageSize(2) <= grid(:,:,2) + tileSize(2);
    gridMask8 = gridMaskR8 & gridMaskC8;
    
    gridMask = gridMask1 | gridMask2 | gridMask3 | gridMask4 | gridMask5...
        |gridMask6 | gridMask7 | gridMask8;
    
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
            canvases{1,index} = uint16(canvas);
        end
    end
end