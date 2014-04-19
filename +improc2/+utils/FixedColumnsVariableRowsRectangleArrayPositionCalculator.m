classdef FixedColumnsVariableRowsRectangleArrayPositionCalculator < handle

    properties (SetAccess = private)
        minimumNumberOfRows
        numberOfColumns
    end
    
    methods
        function p = FixedColumnsVariableRowsRectangleArrayPositionCalculator(...
                numberOfColumns, minimumNumberOfRows)
            if nargin < 1
                numberOfColumns = 1;
            end
            if nargin < 2
                minimumNumberOfRows = 0;
            end
            p.numberOfColumns = numberOfColumns;
            p.minimumNumberOfRows = minimumNumberOfRows;
        end
        
        function position = getPositionOfRectangleInArray(p, rectangleIndex, ...
                totalNumberOfRectangles)
            
            widthOfEveryButton = 1 / p.numberOfColumns;
            
            columnNumber = 1 + mod(rectangleIndex - 1, p.numberOfColumns);
            xPos = (columnNumber - 1) * widthOfEveryButton;
            
            numberOfRowsToFitRectangles = ceil(totalNumberOfRectangles / p.numberOfColumns);
            numberOfRows = max(numberOfRowsToFitRectangles, p.minimumNumberOfRows);
            heightOfEveryButton = 1 / numberOfRows;
            
            rowNumber = ceil(rectangleIndex / p.numberOfColumns);            
            yPos = 1 - rowNumber * heightOfEveryButton;
            
            position = [xPos, yPos, widthOfEveryButton, heightOfEveryButton];
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
end

