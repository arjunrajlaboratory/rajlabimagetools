classdef ChannelArray
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        cellArray1d
    end
    
    properties (SetAccess = private)
        channelNames
    end
    
    methods
        function p = ChannelArray(channelNames)
            p.cellArray1d = cell(numel(channelNames));
            p.channelNames = channelNames;
        end
        function p = setByChannelName(p, value, name)
            index = find(strcmp(p.channelNames, name));
            p.cellArray1d{index} = value;
        end
        function value = getByChannelName(p, name)
            index = find(strcmp(p.channelNames, name));
            value = p.cellArray1d{index};
        end
        function [varargout] = applyForEachChannel(p, funcHandle, varargin)
            for i = 1:nargout
                varargout{i} = dentist.utils.ChannelArray(p.channelNames);
            end
            resultItem = cell(1,nargout);
            for channelName = p.channelNames
                item = p.getByChannelName(channelName);
                [resultItem{:}] = funcHandle(item, varargin{:});
                for i = 1:nargout
                    varargout{i} = varargout{i}.setByChannelName(...
                        resultItem{i}, channelName);
                end
            end
        end
    end
    
end

