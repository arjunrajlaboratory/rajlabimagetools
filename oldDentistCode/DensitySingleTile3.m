%--------------------------------------------------------------------------
% INPUTS
%     chanImages        Contains all the images which are to be processed
%                       for spots in separate cells
%     dapiImage         Will be used to get centroids
%     tileRow,tileCol   Current row,col in relation to scan
%     rowMax,rowCol     Number of rows and columns in scan
%     overlap           Overlap between tiles that was either entered
%                       manually or received from getOverlap GUI
%     imageSize         Size of single tile (usually [1024 1024])
% OUTPUTS
%     tileNuclei        [nucleus1, nucleus2, ...] where each nucleus is of
%                       class Nucleus
%     tileSpots         N cells (N is # of channels) with each cell
%                       containing a matrix of size M by 3 where M is
%                       number of spots.  Each row is of form 
%                       [row,col,spotInt] where row,col is spot location
%                       and spotInt is spot intensity
%     tileSpotVals      N cells (N is # of channels) with each cell
%                       containing a sampling of spot intensity values.
%                       This will be used to plot the threshold-axis
%     tileThresh        N cells (N is # of channels) with each cell
%                       containing the threshold value that was produced by
%                       autothreshold for that tile
%     centroids         M by 2 matrix where M is number of centroids with
%                       each row of form [row,col]
%--------------------------------------------------------------------------
function [tileNuclei,tileSpots,tileSpotVals, tileThresh, centroids] = DensitySingleTile2(chanImages,dapiImage,tileRow,tileCol,rowMax,colMax,overlap,imageSize)
    Hs.tileRow = tileRow;
    Hs.tileCol = tileCol;
    Hs.imageSize = imageSize;
    Hs.rowMax = rowMax;
    Hs.colMax = colMax;
    Hs.overlap = overlap;
    Hs.tileSize = size(dapiImage);

    Hs.img = dapiImage;
    [Hs,nuclei,centroids] = processForDapi(Hs);
    tileNuclei = nuclei;
    
    tileSpots = [];
    tileSpotVals = [];
    tileThresh = [];
    for chanImage = chanImages
        chanImage = cell2mat(chanImage);
        Hs.img = chanImage;
        [Hs,spotInd,spotVal] = processForSpots(Hs);
        tileSpots = [tileSpots,mat2cell(spotInd)];
        tileSpotVals = [tileSpotVals,mat2cell(spotVal)];
        tileThresh = [tileThresh,mat2cell(Hs.threshold)];
    end        
end
function [Hs,spotInd, spotVal] = processForSpots(Hs)

    % Leftmost column is dark and results in spots being detected.  This
    % column is removed
    Hs.img = Hs.img(:,2:end);
    
    %Filters out low frequency noise
    %Deconstruct into frequency ranges
    [aTrous, Aj] = aTrousWaveletTransform(Hs.img,'numLevels',3,'sigma',2);
    %Reconstructing image without low frequencies by summing across third
    %dimension (the frequency dimension)
    Hs.imgAT = sum(aTrous,3);
    %imshow(imgAT>100);
    % find regional maxima in segmented image
    % bw is an array the same size as the image which contains 1's and 0's
    % 1 if it is a regionalmax and 0 if it is not
    Hs.bw = imregionalmax(Hs.imgAT);
    Hs.regionalMaxValues = Hs.imgAT(Hs.bw);

    Hs.regionalMaxIndices = find(Hs.bw);
    %Sort in ascending order
    [Hs.regionalMaxValues,I] = sort(Hs.regionalMaxValues,'ascend');
   % display(Hs.regionalMaxValues);
    Hs.regionalMaxIndices = Hs.regionalMaxIndices(I);
    %Auto threshold
    [Hs.threshold] = imregmaxThresh(Hs.regionalMaxValues);
    if isempty(Hs.threshold)
        Hs.threshold = max(Hs.regionalMaxValues) + 1; %beyond max
    end
    %Dividing the auto-threshold by 2 in order to get all spots that would
    %reasonably be desired.  This avoids having to reprocess every time
    %user adjusts the threshold
%     display('max below');
%     display(max(Hs.regionalMaxValues));
    spotVal = round(Hs.regionalMaxValues * 100);
    
    spotVal = spotVal/100;
%     spotVal = Hs.regionalMaxValues;
    table = tabulate(spotVal);
    spotVal = table(:,1:2);
    

    %----------------------------------------------------------------------
%     % Plot single table
%     figure;
%     axH = axis;
%     display(strcat('Threshold: ',int2str(Hs.threshold)));
%     
% %     display(size(table));
%     table2 = zeros(size(table));
%     table2(:,1) = table(:,1);
%     for r = 1:size(table,1)
%         table2(r,2) = sum(table(r:end,2));
%     end
% %     display(size(table2));
%     maxNum = max(table2(:,2));
%     dataH = plot(table2(:,1),log(table2(:,2)),'b');
%     hold on;
%     plot([Hs.threshold, Hs.threshold],[0, log(maxNum) + 1],'g');
%     xlim([1 size(table,1)]);
%     ylim([0, log(maxNum) + 1]); 
    
    
    %----------------------------------------------------------------------
%     spotVal = table(:,2);

    
    %     spotVal = Hs.regionalMaxValues(Hs.regionalMaxValues > (Hs.threshold/2));
%     spotVal = Hs.regionalMaxValues(Hs.regionalMaxValues > (Hs.threshold));
    spotInds = Hs.regionalMaxIndices(Hs.regionalMaxValues>(Hs.threshold/2));
    spotInt = Hs.regionalMaxValues(Hs.regionalMaxValues>(Hs.threshold/2));
%     display('----------------------------------------------');
%     display(size(spotVal,1));
%     display(size(spotInds,1));
    [row,col] = ind2sub(size(Hs.bw),spotInds);  % convert 1D to 2D
    %Convert to absolute values
    row = row + ((Hs.tileRow-1) * (Hs.imageSize(1) - Hs.overlap));
    col = col + ((Hs.tileCol-1) * (Hs.imageSize(2) - Hs.overlap));
%     display(numel(row));
    
    % Since the leftmost column was deleted, add one to column indice to
    % ensure proper coordinates
    col = col + 1;
    spotInd = [row col spotInt];
%     display(size(spotInd,1));
%     display('----------------------------------------------');

end
% -------------------------------------------------------------------------
% Input
% - Hs.img containing tmr image
% Following Information computed:
% - Individual nuclei masks - scaled by factor of 0.1
% - Centroids of nuclei
% - Bounding boxes of nuclei - upper left indice, xWidth, yWidth
%--------------------------------------------------------------------------
function [Hs,nuclei,centroids] = processForDapi(Hs)
    BWs = Hs.img;
    
    [aTrous,Aj] = aTrousWaveletTransform(BWs,'numLevels',5,'sigma',3);
    
    BWs = scale(aTrous(:,:,5));
    BWs = im2bw(BWs,graythresh(BWs));
    %Smoothen the objects by eroding the edges
    seD = strel('diamond',1);
    BWs = imerode(BWs,seD);
    BWs = imerode(BWs,seD);
    %Delete any object less than 1200 pixels
    BWs = bwareaopen(BWs,1200);
    Hs.BWs = BWs;
    %Fill the holes
    BWs = imfill(BWs,'holes'); 
    %Retrieve information for each object
    BWObjects = bwconncomp(BWs);
    % Centroids contains the linear indexes of the object centroids,
    % parallel to the masks array (in the same order)
    STATS = regionprops(BWObjects,'Centroid','BoundingBox');
    centroids = [size(STATS,1)];
    ulInds = [];
    widths = [];
    for index = 1:size(STATS,1)
        %Retrieve Centroid information
        row = STATS(index).Centroid(2); %y-coord is row
        col = STATS(index).Centroid(1); %x-coord is col
        %Set the Centroid information
        linIndex = sub2ind(Hs.tileSize,round(row),round(col));
        centroids(index) = linIndex;
        %display(strcat(int2str(row),'-',int2str(col)));
        %Retrieve the bounding box information
        x_width = STATS(index).BoundingBox(1,3);
        y_width = STATS(index).BoundingBox(1,4);
        ulCornerX = STATS(index).BoundingBox(1,1);
        ulCornerY = STATS(index).BoundingBox(1,2);
        ulInd = sub2ind(size(BWs),round(ulCornerY),round(ulCornerX));
        %Set the bounding box information
        ulInds(index,:) = ulInd;
        widths(index,1) = round(x_width);
        widths(index,2) = round(y_width);
        if isempty(y_width)
            display('y_width is empty');
        end
    end
    %----------------------------------------------------------------------
    % Do a stronger erosion to detect connected objects
    %----------------------------------------------------------------------
    seD = strel('diamond',5);
    BWER = imerode(BWs,seD);
    BWER = imerode(BWER,seD);
    BWObjectsER = bwconncomp(BWER);
    STATS = regionprops(BWObjectsER,'Centroid','BoundingBox');
    centroidsER = [size(STATS,1)];
    for index = 1:size(STATS,1)
        %Retrieve Centroid information
        row = STATS(index).Centroid(2); %y-coord is row
        col = STATS(index).Centroid(1); %x-coord is col
        %Set the Centroid information
        linIndex = sub2ind(Hs.tileSize,round(row),round(col));
        centroidsER(index) = linIndex;
    end
    %----------------------------------------------------------------------
    % Cycle through each bounding box and see if multiple centroids are
    % contained in each.  If there are multiple in one box, create a slice
    % of black pixels at the midpoint of the line between the two centroids
    % and perpendicular to this line
    %----------------------------------------------------------------------
    for index = 1:size(ulInds,2) 
        [row,col] = ind2sub(Hs.tileSize,ulInds(index));
         x_width = widths(index,1);
         y_width = widths(index,2);
         xMin = col;
         xMax = col + x_width;
         yMin = row;
         yMax = row + y_width;
         xVert = [xMin,xMax, xMin, xMax];
         yVert = [yMin, yMin, yMax, yMax];
         contCentr = []; %List of contained centroids
         %Cycle through each centroid
         for centroid = centroidsER
            [y,x] = ind2sub(Hs.tileSize,centroid);
            if x >= xMin && x <= xMax && y >= yMin && y <= yMax
                contCentr = [contCentr,centroid];
            end
         end
         Hs.centroidsER = centroidsER;
         %if size(contCentr,1) is greater than 1 then we will delete the
         %pixels on an angle between the two centroids CONTAINED IN THE
         %BOUNDING BOX
         if size(contCentr,2) > 1
             %Place each x,y coord of the centroids in an array
             coords = [];
             for centroid = contCentr
                 [y,x] = ind2sub(Hs.tileSize,centroid);
                 coords = [coords;x,y,0,0];%The 0's act as place-holders
             end
             %Pair up each centroid with its closest counterpart
             %For each centroid cycle through the other centroids and find
             %the closest one
             index = 1;
             while index <= size(coords,1)
                 distances = [];
                 for indexInner = 1:size(coords,1)
                     if indexInner == index
                         distances = [distances,Inf];
                     else
                         distances = [distances,pdist([coords(index,:);coords(indexInner,:)])];
                     end
                 end
                 [~,minIndex] = min(distances);
                 coords(index,:) = [coords(index,1:2),coords(minIndex,1:2)];
                 %To avoid processing twice, can remove the row at minIndex
                 if minIndex ~= index
                    coords = removerows(coords,'ind',minIndex);
                 end
                 index = index + 1;
             end
             %Each row now contains four numbers. x1,y1,x2,y2 where 1 is
             %a centroid and 2 its partner centroid
             for index = 1:size(coords,1)
                 %Get the formula for the line which is perpendicular to 
                 %the line between the two centroids and intersects at the
                 %midpoint
                 midpoint = [round((coords(1,1) + coords(1,3))/2),round((coords(1,2) + coords(1,4))/2)];
                 Hs.midpoint = midpoint;
        
                 slope = (coords(1,4) - coords(1,2))/(coords(1,3) - coords(1,1));
                 slope = -1/slope;
                 intercept = midpoint(1,2) - (slope * midpoint(1,1));
                 %Now will process along this line setting the pixel values
                 %to zero.  Must ensure always within bounding box
                 %To the left
                 x = midpoint(1,1);
                 y = round(slope * x + intercept);
                 prevY = inf;
                 while  x >= xMin && x <= xMax && y >= yMin && y <= yMax
                     BWs(y,x) = 0;
                     %If did not have this for loop then the cut will end
                     %up being perforated and not continuous
                     if prevY ~= inf
                         for yChange = min([prevY,y]):max([prevY,y])
                             BWs(yChange,x+1) = 0;
                         end
                     end
                     prevY = y;
                     x = x - 1;
                     y = round(slope * x + intercept);

                 end
                 %We break out of the while loop when x and y are not in the
                 %bounding box.  However, to ensure a contiguous cut we 
                 %should still process a for loop between the previous
                 %point and the edge of the bounding box from which the
                 %while loop exited
                 yBound = [];%The boundary that the y-value crossed
                 if y < yMin
                     yBound = yMin;
                 else
                     yBound = yMax;
                 end
                 if prevY ~= inf
                     for yChange = min([yBound,prevY]):max([yBound,prevY])
                         BWs(yChange,x+1) = 0;
                     end
                 end
                 Hs.midpoint = [x,y];
                 %To the right
                 x = midpoint(1,1);
                 y = round(slope * x + intercept);
                 %Setting to infinit and then checking prevents doing the
                 %row-down each time.  
                 prevY = inf;
                 while x >= xMin && x <= xMax && y >= yMin && y <= yMax
                     BWs(y,x) = 0;
                     %If did not have this for loop then the cut will end
                     %up being perforated and not continuous
                     if prevY ~= inf
                         for yChange = min([prevY,y]):max([prevY,y])
                             BWs(yChange,x-1) = 0;
                         end
                     end
                     prevY = y;
                     x = x + 1;
                     y = round(slope * x + intercept);
                 end
                 %We break out of the while loop when x and y are not in the
                 %bounding box.  However, to ensure a contiguous cut we 
                 %should still process a for loop between the previous
                 %point and the edge of the bounding box
                 yBound = [];%The boundary that the y-value crossed
                 if y < yMin
                     yBound = yMin;
                 else
                     yBound = yMax;
                 end
                 if prevY ~= inf
                     for yChange = min([yBound,prevY]):max([yBound,prevY])
                         BWs(yChange,x-1) = 0;
                     end
                 end
                 Hs.BWs = BWs;

             end
         end
    end
    %----------------------------------------------------------------------
    % Now need to redo the centroid and bounding box information since
    % there could now be more centroids as a result of slicing
    %----------------------------------------------------------------------
    %Retrieve information for each object
    BWObjects = bwconncomp(BWs);
    %Centroids contains the row-col indexes of the object centroids,
    %parallel to the masks array (in the same order)
    STATS = regionprops(BWObjects,'Centroid','BoundingBox');
    nuclei = [];
    centroids = [];
    for index = 1:size(STATS,1)
        %Retrieve Centroid information
        rowRel = STATS(index).Centroid(2); %y-coord is row
        colRel = STATS(index).Centroid(1); %x-coord is col
        %Convert to absolute values
        row = rowRel + ((Hs.tileRow-1) * (Hs.imageSize(1) - Hs.overlap));
        col = colRel + ((Hs.tileCol-1) * (Hs.imageSize(2) - Hs.overlap));
        %Retrieve the bounding box information
        col_width = STATS(index).BoundingBox(1,3);
        row_width = STATS(index).BoundingBox(1,4);
        ulCornerCol = STATS(index).BoundingBox(1,1);
        ulCornerRow = STATS(index).BoundingBox(1,2);
        %Get the mask and add to the masks array
        colMin = ulCornerCol;
        colMax = ulCornerCol + col_width - 1;
        rowMin = ulCornerRow;
        rowMax = ulCornerRow + row_width - 1;
        mask = BWs(rowMin:rowMax,colMin:colMax);
        mask = imresize(mask,0.1);
        
        %Convert to absolute coordinates
        ulCornerRow = ulCornerRow + ((Hs.tileRow-1) * (Hs.imageSize(1) - Hs.overlap));
        ulCornerCol = ulCornerCol + ((Hs.tileCol-1) * (Hs.imageSize(2) - Hs.overlap));

        addSwitch = true;
        %If not a leftmost tile and too close to left side
        if Hs.tileCol ~= 1 && colRel <= Hs.imageSize(2) / 5
            addSwitch = false;
        %If not a rightmost tile and too close to right side
        elseif Hs.tileCol ~= Hs.colMax && colRel >= Hs.tileSize(2) - (Hs.imageSize(2) / 5)
            addSwitch = false;
        %If not a topmost tile and too close to top
        elseif Hs.tileRow ~= 1 && rowRel <= Hs.imageSize(1) / 5
            addSwitch = false;
        %If not bottommost tile and too close to bottom
        elseif Hs.tileRow ~= Hs.rowMax && rowRel >= Hs.tileSize(1) - (Hs.imageSize(1) / 5)
            addSwitch = false;
        end
        if addSwitch
            %Set the Centroid information
            centroids= [centroids;row,col];
            %Create the nucleus and add to the nuclei array if its not too
            nuclei = [nuclei,Nucleus([ulCornerRow,ulCornerCol],[row_width,col_width],mask,[row,col])];
        end
    end    
end