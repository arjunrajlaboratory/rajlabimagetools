classdef PositionArray
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        Nrows;
        Ncols;
    end
    
    properties (SetAccess = private, GetAccess = private)
        cellArray
    end
    
    methods
        function p = PositionArray(Nrows, Ncols)
            p.Nrows = Nrows;
            p.Ncols = Ncols;
            p.cellArray = cell(p.Nrows, p.Ncols);
        end
        function result = getByPosition(p, varargin)
           [row, col] = dentist.utils.asRowAndColumn(varargin{:});
           result = p.cellArray{row, col};
        end
        function p = setByPosition(p, value, varargin)
            [row, col] = dentist.utils.asRowAndColumn(varargin{:});
            p.cellArray{row, col} = value;
        end
        
        function aggregated = aggregateAllPositions(p, aggregationFUNC)
            isFirstIteration = true;
            for i = 1:p.Nrows;
                for j = 1:p.Ncols;
                    if isFirstIteration
                        aggregated = p.cellArray{i, j};
                        isFirstIteration = false;
                    else
                        aggregated = aggregationFUNC(aggregated, p.cellArray{i,j});
                    end
                end
            end
        end
        
    end
    
end

