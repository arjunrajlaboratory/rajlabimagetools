classdef ThresholdPlotPlugin < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        thresholdsHolder
        frequencyTableSource
        axH
        thresholdLineH
        histogramLineH
        channelHolder
        mostRecentChannelPlotted;
    end
    
    methods
        function p = ThresholdPlotPlugin(axH, thresholdsHolder, ...
                frequencyTableSource, channelHolder)
            p.axH = axH;
            p.thresholdsHolder = thresholdsHolder;
            p.frequencyTableSource = frequencyTableSource;
            p.channelHolder = channelHolder;
        end
        
        function draw(p)
            channelName = p.channelHolder.getChannelName();
            spotTable = p.frequencyTableSource.getSpotFrequencyTable(channelName);
            frequencies = spotTable.frequencies;
            intensities = spotTable.values;
            cumFrequencies = cumsum(frequencies);
            totalSpots = sum(spotTable.frequencies);
            p.clearHistogramLine()
            p.histogramLineH = line(intensities, log10(totalSpots - cumFrequencies), ...
                'HitTest', 'off', 'Parent', p.axH, 'Color', 'k');
            if isempty(p.mostRecentChannelPlotted) || ...
                    ~strcmp(channelName, p.mostRecentChannelPlotted)
                set(p.axH, 'XLim', [0, max(intensities)])
                p.mostRecentChannelPlotted = channelName;
            end
            p.drawThresholdLine();
        end

        
        function drawThresholdLine(p)
            channelName = p.channelHolder.getChannelName();
            p.clearThresholdLine();
            ylims = get(p.axH, 'YLim');
            threshold = p.thresholdsHolder.getThreshold(channelName);
            p.thresholdLineH = line([threshold threshold], ylims, ...
                'Parent', p.axH, 'Color', 'b', 'HitTest', 'off');
        end
            
        function clearThresholdLine(p)
            if ~isempty(p.thresholdLineH) && ishandle(p.thresholdLineH)
                delete(p.thresholdLineH)
            end
        end
        
        function clearHistogramLine(p)
            if ~isempty(p.histogramLineH) && ishandle(p.histogramLineH)
                delete(p.histogramLineH)
            end
        end
        
        function setThreshold(p, value)
            channelName = p.channelHolder.getChannelName();
            p.thresholdsHolder.setThreshold(value, channelName)
            p.drawThresholdLine();
        end 
    end
    
end

