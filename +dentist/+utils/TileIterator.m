classdef TileIterator < handle
    %UNTITLED15 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        Nrows
        Ncols
    end
    
    properties (SetAccess = private, GetAccess = private)
        tile
        hasYieldedOneTile = false;
    end
    
    properties (Dependent = true)
        totalNumOfTiles
    end
    
    properties (Dependent = true, GetAccess = private, SetAccess = private)
        currentTileNumber
    end
    
    methods
        function p = TileIterator(Nrows, Ncols)
            p.Nrows = Nrows;
            p.Ncols = Ncols;
            p.tile = dentist.utils.TilePosition(Nrows, Ncols, 1, 1);
        end
        
        function TF = hasNext(p)
            if p.hasYieldedOneTile
                TF = p.currentTileNumber < p.totalNumOfTiles;
            else
                TF = true;
            end
        end
        
        function num = get.totalNumOfTiles(p)
            num = p.Nrows * p.Ncols;
        end
        
        function num = get.currentTileNumber(p)
            num = p.tile.tileNumber;
        end
        
        function tile = next(p)
            assert(p.hasNext, 'No more tiles to yield')
            if p.hasYieldedOneTile
                p.tile = p.tile.goToNumber(p.currentTileNumber + 1);
            else
                p.hasYieldedOneTile = true;
            end
            tile = p.tile;
        end
    end
    
end

