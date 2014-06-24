classdef SliceInspectorGUIManager < handle
    
    properties (Access = private)
        buildResources = struct();
        sliceBrowser
        figH
        keyboardInterpreter
    end
    
    methods
        function p = SliceInspectorGUIManager(buildResources)
            p.buildResources.channelSwitcher = buildResources.channelSwitcher;
            p.buildResources.viewportHolder = buildResources.viewportHolder;
            p.buildResources.objectHandle = buildResources.objectHandle;
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
            TF = ~isempty(p.sliceBrowser) && isvalid(p.sliceBrowser);
        end
        function updateIfActive(p)
            if p.isActive()
                p.sliceBrowser.draw()
            end
        end
        function goUpOneSlice(p)
            if p.isActive()
                p.sliceBrowser.goUpOneSlice()
            end
        end
        function goDownOneSlice(p)
            if p.isActive()
                p.sliceBrowser.goDownOneSlice()
            end
        end
    end
    
    methods (Access = private)
        function figureCloseRequest(p, varargin)
            delete(p.sliceBrowser)
            delete(p.figH)
        end
        
        function buildGUI(p)
            figH = figure('NumberTitle','off',...
                'Name','Up, Down arrows. Drag, left/right/double click',...
                'Resize','on',...
                'Toolbar','none',...
                'MenuBar','none',...
                'HandleVisibility', 'callback', ...
                'Position', [200, 150, 450, 450], ...
                'Color',[0.247 0.247 0.247], ...
                'Colormap', bone(32));
            
            axH = axes('Parent', figH, ...
                'Units', 'normalized', ...
                'Position', [0.01 0.01 0.98 0.98], ...
                'XTick',[],'YTick',[]);
            axis(axH, 'equal')
            
            p.buildResources.axH = axH;
            
            sliceBrowser = improc2.thresholdGUI.ImageSliceBrowser(p.buildResources);
            sliceBrowser.draw();
            
            sliceInspectorZoomInterpreter = ...
                dentist.utils.ImageZoomingMouseInterpreter(p.buildResources.viewportHolder);
            sliceInspectorZoomInterpreter.wireToFigureAndAxes(figH, axH);
            
            set(figH, 'CloseRequestFcn', @(varargin) p.figureCloseRequest())
            p.sliceBrowser = sliceBrowser;
            p.figH = figH;
        end
    end
end

