function [centroids] = findCentroidsInImage(imageSource, verboseFlag)
    if nargin < 2
        verboseFlag = false;
    end
    
    if isnumeric(imageSource)
        dapiImage = imageSource;
    else 
        dapiImage = imageSource.getExtendedDapiImage;
    end
        
    BWs = dapiImage;
    
    [aTrous,Aj] = aTrousWaveletTransform(BWs,'numLevels',5,'sigma',3);
    
    BWs = scale(aTrous(:,:,5));
    BWs = im2bw(BWs,graythresh(BWs));
    %Smoothen the objects by eroding the edges
    seD = strel('diamond',1);
    BWs = imerode(BWs,seD);
    BWs = imerode(BWs,seD);
    %Delete any object less than 1200 pixels
    BWs = bwareaopen(BWs,1200);
    %Fill the holes
    BWs = imfill(BWs,'holes'); 
    % Remove objects that are on the border - except for the borders that
    % are on the border of the scan
    if ~isnumeric(imageSource)
        % Add padding to sides that are on borders of scan
        if ~imageSource.hasNeighbor('up')
           BWs = [zeros(1,size(BWs,2)); BWs]; 
        end
        if ~imageSource.hasNeighbor('down')
            BWs = [BWs; zeros(1,size(BWs,2))];
        end
        if ~imageSource.hasNeighbor('right')
            BWs = [BWs, zeros(size(BWs,1),1)];
        end
        if ~imageSource.hasNeighbor('left')
            BWs = [zeros(size(BWs,1),1), BWs];
        end
        BWs = imclearborder(BWs);
        % Remove this padding
        if ~imageSource.hasNeighbor('up')
           BWs = BWs(2:end,:);
        end
        if ~imageSource.hasNeighbor('down')
            BWs = BWs(1:end-1,:);
        end
        if ~imageSource.hasNeighbor('right')
            BWs = BWs(1:end,1:end-1);
        end
        if ~imageSource.hasNeighbor('left')
            BWs = BWs(1:end,2:end);
        end
    end
    
    
    
    
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
        linIndex = sub2ind(size(dapiImage),round(row),round(col));
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
        linIndex = sub2ind(size(dapiImage),round(row),round(col));
        centroidsER(index) = linIndex;
    end
    %----------------------------------------------------------------------
    % Cycle through each bounding box and see if multiple centroids are
    % contained in each.  If there are multiple in one box, create a slice
    % of black pixels at the midpoint of the line between the two centroids
    % and perpendicular to this line
    %----------------------------------------------------------------------
    for index = 1:size(ulInds,2) 
        [row,col] = ind2sub(size(dapiImage),ulInds(index));
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
            [y,x] = ind2sub(size(dapiImage),centroid);
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
                 [y,x] = ind2sub(size(dapiImage),centroid);
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
    
    centroids = [];
    for index = 1:size(STATS,1)
        %Retrieve Centroid information
        rowRel = STATS(index).Centroid(2); %y-coord is row
        colRel = STATS(index).Centroid(1); %x-coord is col
        %Convert to absolute values
 %%%%%%%%       row = rowRel + ((Hs.tileRow-1) * (Hs.imageSize(1) - Hs.overlap));
 %%%%%%%%       col = colRel + ((Hs.tileCol-1) * (Hs.imageSize(2) - Hs.overlap));
    
%         dapiImageSize = size(dapiImage);
%         addSwitch = true;
%         %If not a leftmost tile and too close to left side
%         if tileCol ~= 1 && colRel <= imageSize(2) / 5
%             addSwitch = false;
%         %If not a rightmost tile and too close to right side
%         elseif tileCol ~= tileNumCols && colRel >= dapiImageSize(2) - (imageSize(2) / 5)
%             addSwitch = false;
%         %If not a topmost tile and too close to top
%         elseif tileRow ~= 1 && rowRel <= imageSize(1) / 5
%             addSwitch = false;
%         %If not bottommost tile and too close to bottom
%         elseif tileRow ~= tileNumRows && rowRel >= dapiImageSize(1) - (imageSize(1) / 5)
%             addSwitch = false;
%         end
%         if addSwitch
%             %Set the Centroid information
%             centroids= [centroids;rowRel,colRel];
%         end
        centroids = [centroids; rowRel, colRel];
    end    
    centroids = dentist.utils.Centroids(centroids(:,2),centroids(:,1));
    
    if verboseFlag
        figure(1);
        imshow(imadjust(dapiImage),'InitialMagnification','fit')
        plotCirclesAtCoordinates(centroids.xPositions,centroids.yPositions);
    end
    
end

function plotCirclesAtCoordinates(x, y)
    hold on;
    plot(x,y,'or');
    hold off;
end
