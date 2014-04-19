classdef PositionAndChannelArray
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        Nrows;
        Ncols;
        channelNames
    end
    
    properties (SetAccess = private, GetAccess = private)
        cellArray
    end
    
    methods
        function p = PositionAndChannelArray(Nrows, Ncols, channelNames)
            p.Nrows = Nrows;
            p.Ncols = Ncols;
            p.channelNames = channelNames;
            p.cellArray = cell(p.Nrows, p.Ncols, numel(p.channelNames));
        end
        function result = getByChannelByPosition(p, channelName, varargin)
            [row, col] = dentist.utils.asRowAndColumn(varargin{:});
            channelIndex = find(strcmp(p.channelNames, channelName));
            result = p.cellArray{row, col, channelIndex};
        end
        function p = setByChannelByPosition(p, value, channelName, varargin)
            [row, col] = dentist.utils.asRowAndColumn(varargin{:});
            channelIndex = find(strcmp(p.channelNames, channelName));
            p.cellArray{row, col, channelIndex} = value;
        end
        function p = setByPosition(p, channelArray, varargin)
            if ~isa(channelArray,'dentist.utils.ChannelArray')
                error('Value must be a ChannelArray');
            end
            for channelName = p.channelNames
                value = channelArray.getByChannelName(channelName);
                p = p.setByChannelByPosition(value,channelName, varargin{:});
            end
        end
        
        function channelArray = aggregateAllPositions(p, aggregationFUNC)
            channelArray = dentist.utils.ChannelArray(p.channelNames);
            for channelIndex = 1:length(p.channelNames)
                channelName = p.channelNames{channelIndex};
                isFirstIteration = true;
                for i = 1:p.Nrows;
                    for j = 1:p.Ncols;
                        if isFirstIteration
                            aggregated = p.cellArray{i, j, channelIndex};
                            isFirstIteration = false;
                        else
                            aggregated = aggregationFUNC(...
                                aggregated, p.cellArray{i,j,channelIndex});
                        end
                    end
                end
                channelArray = channelArray.setByChannelName(aggregated, channelName);
            end
        end
        
    end
end

