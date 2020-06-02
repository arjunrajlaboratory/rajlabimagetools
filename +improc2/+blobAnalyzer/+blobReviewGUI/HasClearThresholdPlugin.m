classdef HasClearThresholdPlugin < handle
    
    properties
        processorDataHolder
        hasClearThresholdUI
    end
    
    methods
        function p = HasClearThresholdPlugin(processorDataHolder)
            p.processorDataHolder = processorDataHolder;
        end
        
        function draw(p)
            p.syncWithHasClearThresholdUI()
        end
        
        function setHasClearThreshold(p, yesNoOrNA)
            p.processorDataHolder.processorData.hasClearThreshold = yesNoOrNA;
        end
        function yesNoOrNA = getHasClearThreshold(p)
            yesNoOrNA = p.processorDataHolder.processorData.hasClearThreshold;
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
        function hasClearThresholdUICallback(p)
            choices = {'NA', 'yes', 'no'};
            value = choices{get(p.hasClearThresholdUI, 'Value')};
            p.processorDataHolder.processorData.hasClearThreshold = value;
        end
        
        function syncWithHasClearThresholdUI(p)
            if ishandle(p.hasClearThresholdUI)
                yesNoOrNA = p.getHasClearThreshold();
                set(p.hasClearThresholdUI, 'Value', ...
                    find(strcmp(yesNoOrNA, {'NA', 'yes', 'no'})));
            end
        end
    end 
end

