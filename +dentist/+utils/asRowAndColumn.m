function [row, col] = asRowAndColumn(varargin)
    if length(varargin) == 1
        tile = varargin{1};
        row = tile.row;
        col = tile.col;
    elseif length(varargin) == 2
        row = varargin{1};
        col = varargin{2};
    else
        error('Position should be specified as a tile or as row, col')
    end

end

