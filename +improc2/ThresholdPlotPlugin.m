classdef ThresholdPlotPlugin < handle
    
    properties (Access = private)
        axH
        processorDataHolder
        histogramLineH;
        thresholdLineH;
        plotLogY = true;
        automaticXAxisMax = true;
        saturationValuesSource;
    end
    
    properties (SetAccess = protected, GetAccess = protected)
        plotLogYUI;
        hasClearThresholdUI;
        autoXAxisUI;
    end
    
    
    methods
        function p = ThresholdPlotPlugin(axH, processorDataHolder, saturationValuesSource)
            p.axH = axH;
            p.processorDataHolder = processorDataHolder;
            p.saturationValuesSource = saturationValuesSource;
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
        
        function draw(p)
            
            p.clearHistogramLine()
            
            proc = p.processorDataHolder.processorData;
            ranksOfRegionalMaxima = numel(proc.regionalMaxValues):-1:1;
            if p.plotLogY
                ranksOfRegionalMaxima = log(ranksOfRegionalMaxima);
            end
            
            intensitiesOfRegionalMaxima = proc.regionalMaxValues;
            p.histogramLineH = line(proc.regionalMaxValues, ranksOfRegionalMaxima, ...
                'HitTest', 'off', 'Parent', p.axH, ...
                'Color', 'k');
            
            xAxisMin = intensitiesOfRegionalMaxima(1);
            if p.automaticXAxisMax
                xAxisMax = intensitiesOfRegionalMaxima(end) * 1.05;
            else
                xAxisMax = p.saturationValuesSource.getSaturationValue();
            end
            
            set(p.axH, 'XLim', [xAxisMin xAxisMax]);
            
            totalNumberOfRegionalMaxima = ranksOfRegionalMaxima(1);
            if ~p.plotLogY
                yaxismax = min(proc.getNumSpots() * 2, totalNumberOfRegionalMaxima);
                yaxismax = max(10, yaxismax);
            else
                yaxismax = totalNumberOfRegionalMaxima * 1.1;
            end
            set(p.axH, 'YLim', [0 yaxismax]);
            
            p.clearThresholdLine()
            
            threshold = proc.threshold;
            p.thresholdLineH = line([threshold threshold], [0 yaxismax], ...
                'Parent', p.axH, 'Color', 'b', 'HitTest', 'off');
            
            p.syncWithHasClearThresholdUI()
        end
        
        function setAutomaticXAxis(p, trueOrFalse)
            assert(islogical(trueOrFalse) && isscalar(trueOrFalse), ...
                'improc2:BadArguments', 'input should be true or false')
            p.automaticXAxisMax = trueOrFalse;
            p.draw();
            p.syncWithAutoXAxisUI();
        end
        
        function setPlotLogY(p, trueOrFalse)
            assert(islogical(trueOrFalse) && isscalar(trueOrFalse), ...
                'improc2:BadArguments', 'input should be true or false')
            p.plotLogY = trueOrFalse;
            p.draw;
            p.syncWithPlotLogYUI;
        end
        
        function setHasClearThreshold(p, yesNoOrNA)
            p.processorDataHolder.processorData.hasClearThreshold = yesNoOrNA;
        end
        
        function attachAutomaticXAxisControl(p, uihandle)
            p.autoXAxisUI = uihandle;
            set(p.autoXAxisUI, 'Max', true, 'Min', false);
            set(p.autoXAxisUI, 'Value', p.automaticXAxisMax);
            set(p.autoXAxisUI, 'Callback', @(varargin) p.autoXAxisUICallback())
        end
        
        function attachPlotLogYUIControl(p, uihandle)
            p.plotLogYUI = uihandle;
            set(p.plotLogYUI, 'Max', true, 'Min', false);
            set(p.plotLogYUI, 'Value', p.plotLogY);
            set(p.plotLogYUI, 'Callback', @(varargin) p.plotLogYUICallback())
        end
        
        function attachHasClearThresholdUIControl(p, uihandle)
            p.hasClearThresholdUI = uihandle;
            set(p.hasClearThresholdUI, 'String', {'NA', 'yes', 'no'});
            p.syncWithHasClearThresholdUI();
            set(p.hasClearThresholdUI, 'Callback', ...
                @(varargin) p.hasClearThresholdUICallback())
        end
    end
    
    methods (Access = private)
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
        
        function plotLogYUICallback(p)
            p.setPlotLogY(logical(get(p.plotLogYUI, 'Value')));
        end
        
        function autoXAxisUICallback(p)
            p.setAutomaticXAxis(logical(get(p.autoXAxisUI, 'Value')));
        end
        
        function hasClearThresholdUICallback(p)
            choices = {'NA', 'yes', 'no'};
            value = choices{get(p.hasClearThresholdUI, 'Value')};
            p.processorDataHolder.processorData.hasClearThreshold = value;
        end
        
        function syncWithHasClearThresholdUI(p)
            if ishandle(p.hasClearThresholdUI)
                yesNoOrNA = p.processorDataHolder.processorData.hasClearThreshold;
                set(p.hasClearThresholdUI, 'Value', ...
                    find(strcmp(yesNoOrNA, {'NA', 'yes', 'no'})));
            end
        end
        
        function syncWithPlotLogYUI(p)
            if ishandle(p.plotLogYUI)
                set(p.plotLogYUI, 'Value', p.plotLogY)
            end
        end
        
        function syncWithAutoXAxisUI(p)
            if ishandle(p.autoXAxisUI)
                set(p.autoXAxisUI, 'Value', p.automaticXAxisMax)
            end
        end
    end
    
end

