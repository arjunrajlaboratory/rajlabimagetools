classdef SegmentInspectorGUIManager < handle
    
    properties (Access = private)
        buildResources = struct();
        segmentViewer
        figH
        keyboardInterpreter
    end
    
    methods
        function p = SegmentInspectorGUIManager(buildResources)
            % Needs to be updated with whatever items are required to build
            % this.
            % Probably need to get a ChannelStkContainer.
            p.buildResources.channelSwitcher = buildResources.channelSwitcher;
            p.buildResources.viewportHolder = buildResources.viewportHolder; % Probably okay. Need to figure out how this works, though.
            p.buildResources.objectHandle = buildResources.objectHandle; % Not sure where this gets used.
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
        function TF = isActive(p) % Can I leave this alone?
            TF = ~isempty(p.segmentViewer) && isvalid(p.segmentViewer);
        end
        
        function updateIfActive(p) % Probably can leave this alone. Just tells it to draw itself.
            if p.isActive()
                p.segmentViewer.draw()
            end
        end
        
        function goUpOneSlice(p)  % These can probably be removed. Can probably be transformed into "changeCurrObject" methods
            if p.isActive()
                p.segmentViewer.goUpOneSlice()
            end
        end
        function goDownOneSlice(p)  % These can probably be removed. Can probably be transformed into "changeCurrObject" methods
            if p.isActive()
                p.segmentViewer.goDownOneSlice()
            end
        end
        
        % Design choice: can either make a monolithic "update" that stores
        % the current array choice and thus decides whether to make a major
        % or minor update accordingly. Or can make a small and big update
        % that listen to object and array change events. Hmm. I think the
        % latter might "fit" a bit better with the rest of the design
        % philosophy, and would avoid some potential awkwardness with
        % storing the current array and comparing it.
        
        % major update
        function updateWithNewArray(p) % This can update based on a new array. Hook for adding this in as a callback.
        end
        
        % minor update
        function updateWithNewObject(p) % This can update based on a new object. Hook for adding this in as a callback.
            if p.isActive() % What is this "active" thing about?
                p.segmentViewer.changeCurrentObject() % Prolly need to send along the object number somehow.
            end
        end
    end
    
    methods (Access = private)
        function figureCloseRequest(p, varargin) % Pretty sure this can just remain as is.
            delete(p.segmentViewer)
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
            
            segmentViewer = improc2.thresholdGUI.SegmentViewer(p.buildResources);
            segmentViewer.draw();
            
            segmentInspectorZoomInterpreter = ...
                dentist.utils.ImageZoomingMouseInterpreter(p.buildResources.viewportHolder);
            segmentInspectorZoomInterpreter.wireToFigureAndAxes(figH, axH);
            
            set(figH, 'CloseRequestFcn', @(varargin) p.figureCloseRequest())
            p.segmentViewer = segmentViewer;
            p.figH = figH;
        end
    end
end

