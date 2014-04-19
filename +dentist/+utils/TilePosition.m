classdef TilePosition
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        Nrows;
        Ncols;
        row = 1;
        col = 1;
    end
    
    properties (Dependent = true)
        tileNumber
    end
    
    methods
        function p = TilePosition(Nrows, Ncols, varargin)
            p.Nrows = Nrows;
            p.Ncols = Ncols;
            switch length(varargin)
                case 0
                    p = p.goToNumber(1);
                case 1
                    p = p.goToNumber(varargin{1});
                case 2
                    row = round(varargin{1});
                    col = round(varargin{2});
                    assert(0 < row && row <= Nrows && 0 < col && col <= Ncols, ...
                        'row and column number must be between 1 and Nrow/Ncol')
                    p.row = row;
                    p.col = col;
            end
        end
        
        %% tileNumber
        
        function tileNum = get.tileNumber(p)
            tileNum = sub2ind([p.Nrows, p.Ncols], p.row, p.col);
        end
        
        function p = goToNumber(p, num)
            tileNum = round(num);
            assert(0 < tileNum && tileNum <= p.Nrows * p.Ncols, ...
                'TileNumber must be between 1 and Nrows*Ncols inclusive.')
            [p.row, p.col] = ind2sub([p.Nrows, p.Ncols], tileNum);
        end 
            
        %% Navigate to edge
        
        function p = goToEdge(p, edgeDirection)
            switch char(edgeDirection)
                case {'top', 'up'}
                    p.row = 1;
                case {'bottom', 'down'}
                    p.row = p.Nrows;
                case 'left'
                    p.col = 1;
                case 'right'
                    p.col = p.Ncols;
            end
        end
        
        %% Get neighboring tiles
        
        function TF = hasNeighbor(p, neighborDirection)
            switch char(neighborDirection)
                case 'up'
                    TF = ~p.isAtTopEdge;
                case 'down'
                    TF = ~p.isAtBottomEdge;
                case 'left'
                    TF = ~p.isAtLeftEdge;
                case 'right'
                    TF = ~p.isAtRightEdge;
                case 'up-left'
                    TF = ~p.isAtTopEdge && ~p.isAtLeftEdge;
                case 'up-right'
                    TF = ~p.isAtTopEdge && ~p.isAtRightEdge;
                case 'down-left'
                    TF = ~p.isAtBottomEdge && ~p.isAtLeftEdge;
                case 'down-right'
                    TF = ~p.isAtBottomEdge && ~p.isAtRightEdge;
                otherwise
                    error('neighborDirection not recognized')
            end
        end 
        
        function newTile = getNeighbor(p, neighborDirection)
            newRowNum = p.row;
            newColNum = p.col;
            
            neighborDirection = char(neighborDirection);
            
            assert(p.hasNeighbor(neighborDirection), 'At an edge: no tile in that direction')
            
            if any(strcmp(neighborDirection, {'up', 'up-left', 'up-right'}))
                newRowNum = newRowNum - 1;
            elseif any(strcmp(neighborDirection, {'down', 'down-left', 'down-right'}))
                newRowNum = newRowNum + 1;
            end
            if any(strcmp(neighborDirection, {'left', 'up-left', 'down-left'}))
                newColNum = newColNum - 1;
            elseif any(strcmp(neighborDirection, {'right', 'up-right', 'down-right'}))
                newColNum = newColNum + 1;
            end
            
            p.row = newRowNum;
            p.col = newColNum;
            
            newTile = p;
            
        end
    end    
        
	methods (Access = private)
        
        function TF = isAtTopEdge(p)
            TF = (p.row == 1);
        end
        function TF = isAtBottomEdge(p)
            TF = (p.row == p.Nrows);
        end
        function TF = isAtLeftEdge(p)
            TF = (p.col == 1);
        end
        function TF = isAtRightEdge(p)
            TF = (p.col == p.Ncols);
        end
        
    end
    
end

