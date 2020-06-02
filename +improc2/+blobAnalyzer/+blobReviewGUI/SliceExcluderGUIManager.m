classdef SliceExcluderGUIManager < handle
    
    properties (Access = private)
        buildResources = struct();
        figH
        keyboardInterpreter
        processorDataHolder
        spotsPerSliceDisplayer
    end
    
    methods
        function p = SliceExcluderGUIManager(buildResources)
            p.processorDataHolder = buildResources.processorDataHolder;
            p.keyboardInterpreter = buildResources.keyboardInterpreter;
        end
        function launchGUI(p)
            if p.isActive()
                figure(p.figH)
            else
                p.buildGUI()
                keyboardInterpreter = p.keyboardInterpreter;
                set(p.figH, 'WindowKeyPressFcn', ...
                    @keyboardInterpreter.keyPressCallBackFunc)
            end
        end
        function TF = isActive(p)
            TF = ~isempty(p.spotsPerSliceDisplayer) && isvalid(p.spotsPerSliceDisplayer);
        end
        function updateIfActive(p)
            if p.isActive()
                p.spotsPerSliceDisplayer.draw()
            end
        end
    end
    
    methods (Access = private)
        function figureCloseRequest(p, varargin)
            delete(p.spotsPerSliceDisplayer)
            delete(p.figH)
        end
        
        function buildGUI(p)
            p.figH = figure('NumberTitle','off',...
                'Resize','on',...
                'Toolbar','none',...
                'MenuBar','none',...
                'HandleVisibility', 'callback', ...
                'Position', [200, 150, 200, 400], ...
                'Color',[0.247 0.247 0.247]);
            axH = axes('Parent', p.figH, ...
                'XColor','w', ...
                'YColor', 'w');
            xlabel('num Spots')
            ylabel('Z slice #')
            clearButton = uicontrol('Style', 'pushbutton',...
                'Parent', p.figH, ...
                'String', 'Clear', ...
                'Units', 'normalized', ...
                'Position', [0.5, 0.95, 0.4, 0.045]);
            
            p.spotsPerSliceDisplayer = ...
                improc2.thresholdGUI.SpotsPerSliceDisplayer(axH, ...
                p.processorDataHolder);
            
            sliceExcluder = improc2.utils.SliceExcluderForRegionalMaxProcData(...
                p.processorDataHolder);
            
            mouseInterpreter = ...
                improc2.thresholdGUI.SliceExclusionMouseInterpreter(sliceExcluder);
            mouseInterpreter.wireToFigureAndAxes(p.figH, axH)
            
            set(clearButton, 'CallBack', @(varargin) sliceExcluder.clearExclusions());
            
            p.spotsPerSliceDisplayer.draw();
            
            set(p.figH, 'CloseRequestFcn', @(varargin) p.figureCloseRequest())
            
        end
    end
end

