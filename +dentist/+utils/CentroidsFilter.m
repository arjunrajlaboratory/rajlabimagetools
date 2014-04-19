classdef CentroidsFilter < handle
    %UNTITLED17 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        numSpotsLowerAndUpperBounds
        lowerBoundUIControls
        upperBoundUIControls
    end
    
    properties (SetAccess = private)
        channelNames
    end
    
    methods
        function p = CentroidsFilter(channelNames)
            assert(~isempty(channelNames), 'channelNames input must not be empty')
            p.channelNames = channelNames;
            p.numSpotsLowerAndUpperBounds = ...
                dentist.utils.ChannelArray(channelNames);
            p.setToDefaults();
        end
        
        function setToDefaults(p)
            p.numSpotsLowerAndUpperBounds = ...
                p.numSpotsLowerAndUpperBounds.applyForEachChannel(@(x) [0, Inf]);
            p.updateBoundsUIControls();
        end
        
        function setNumSpotsLowerBound(p, value, channelName)
            bounds = p.numSpotsLowerAndUpperBounds.getByChannelName(channelName);
            bounds(1) = min(max(0, value), bounds(2));
            p.numSpotsLowerAndUpperBounds = ...
                p.numSpotsLowerAndUpperBounds.setByChannelName(bounds, channelName);
            p.updateBoundsUIControls();
        end
        
        function setNumSpotsUpperBound(p, value, channelName)
            bounds = p.numSpotsLowerAndUpperBounds.getByChannelName(channelName);
            bounds(2) = max(bounds(1), value);
            p.numSpotsLowerAndUpperBounds = ...
                p.numSpotsLowerAndUpperBounds.setByChannelName(bounds, channelName);
            p.updateBoundsUIControls();
        end
        
        function value = getNumSpotsLowerBound(p, channelName)
            bounds = p.numSpotsLowerAndUpperBounds.getByChannelName(channelName);
            value = bounds(1);
        end
        
        function value = getNumSpotsUpperBound(p, channelName)
            bounds = p.numSpotsLowerAndUpperBounds.getByChannelName(channelName);
            value = bounds(2);
        end
        
        function centroidIndices = getPassingCentroidIndices(p, centroidsAndNumSpotsSource)
            centroidPassesFilter = true; % will turn into a vector after first iteration
            for channelName = p.channelNames
                bounds = p.numSpotsLowerAndUpperBounds.getByChannelName(channelName);
                numSpots = centroidsAndNumSpotsSource.getNumSpotsForCentroids(channelName);
                centroidPassesFilter = centroidPassesFilter & ...
                    (numSpots >= bounds(1)) & (numSpots <= bounds(2));
            end
            centroidIndices = find(centroidPassesFilter);
        end
        
        function attachLowerAndUpperBoundUIControls(p, lowerUIArray, upperUIArray)
            for channelName = p.channelNames
                lowerUI = lowerUIArray.getByChannelName(channelName);
                upperUI = upperUIArray.getByChannelName(channelName);
                set(lowerUI, 'Callback', {@p.lowerBoundUICallback, channelName})
                set(upperUI, 'Callback', {@p.upperBoundUICallback, channelName})
            end
            p.lowerBoundUIControls = lowerUIArray;
            p.upperBoundUIControls = upperUIArray;
            p.updateBoundsUIControls();
        end
        
        function lowerBoundUICallback(p, hObject, eventdata, channelName)
            value = get(p.lowerBoundUIControls.getByChannelName(channelName), 'String');
            value = str2num(value);
            if ~isempty(value)
                p.setNumSpotsLowerBound(value, channelName)
            else
                p.updateBoundsUIControls();
            end
        end
        
        function upperBoundUICallback(p, hObject, eventdata, channelName)
            value = get(p.upperBoundUIControls.getByChannelName(channelName), 'String');
            value = str2num(value);
            if ~isempty(value)
                p.setNumSpotsUpperBound(value, channelName)
            else
                p.updateBoundsUIControls();
            end
        end
    end
    
    methods (Access = private)
        function updateBoundsUIControls(p)
            if ~isempty(p.lowerBoundUIControls)
                for channelName = p.channelNames
                    lowerUI = p.lowerBoundUIControls.getByChannelName(channelName);
                    if ishandle(lowerUI)
                        set(lowerUI, 'String', num2str(p.getNumSpotsLowerBound(channelName)))
                    end
                end
            end
            if ~isempty(p.upperBoundUIControls)
                for channelName = p.channelNames
                    upperUI = p.upperBoundUIControls.getByChannelName(channelName);
                    if ishandle(upperUI)
                        set(upperUI, 'String', num2str(p.getNumSpotsUpperBound(channelName)))
                    end
                end
            end
        end
    end
    
end

