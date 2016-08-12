classdef SegmentInspectorGUIManager < handle
    
    properties (Access = private)
        buildResources = struct();
        segmentViewer
        figH
%         keyboardInterpreter
    end
    
    methods
        function p = SegmentInspectorGUIManager(buildResources)
            
            p.buildResources.browsingTools = buildResources.browsingTools;

%             p.keyboardInterpreter = buildResources.keyboardInterpreter;
        end
        
        function launchGUI(p) % This will need an argument of thresholdGUI controls or the navigator.
            if p.isActive()
                figure(p.figH)
            else
                p.buildGUI()
%                 keyboardInterpreter = p.keyboardInterpreter;
%                 set(p.figH, 'WindowKeyPressFcn', ...
%                     @keyboardInterpreter.keyPressCallBackFunc)
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
        
        % major update
        function updateWithNewArray(p) % This can update based on a new array. Hook for adding this in as a callback.
            % This is "glue code"
            if p.isActive() % What is this "active" thing about?
                p.segmentViewer.currentObject = p.buildResources.browsingTools.navigator.currentObjNum;
                p.segmentViewer.currentArray  = p.buildResources.browsingTools.navigator.currentArrayNum;
                
                p.segmentViewer.arrayUpdate;
                p.segmentViewer.draw();
            end

        end
        
        % minor update
        function updateWithNewObject(p) % This can update based on a new object. Hook for adding this in as a callback.
            % This is "glue code"
            if p.isActive() % What is this "active" thing about?
                p.segmentViewer.currentObject = p.buildResources.browsingTools.navigator.currentObjNum;
                p.segmentViewer.currentArray  = p.buildResources.browsingTools.navigator.currentArrayNum;
                
                p.segmentViewer.draw();
            end
        end
    end
    
    methods (Access = private)
        function figureCloseRequest(p, varargin) % Pretty sure this can just remain as is.
            delete(p.segmentViewer) % Do we need a destructor for any local stuff in segmentViewer?
            delete(p.figH)
        end
        
        function buildGUI(p)
            figH = figure('NumberTitle','off',...
                'Name','Segmented cells',...
                'Resize','on',...
                'Toolbar','none',...
                'MenuBar','none',...
                'HandleVisibility', 'callback', ...
                'Position', [900, 150, 450, 450], ...
                'Color',[0.247 0.247 0.247], ...
                'Colormap', bone(32));
            
            axH = axes('Parent', figH, ...
                'Units', 'normalized', ...
                'Position', [0.00 0.00 1 1], ...
                'XTick',[],'YTick',[]);
            axis(axH, 'equal')
            
            p.buildResources.axH = axH;
            p.buildResources.currentObject = p.buildResources.browsingTools.navigator.currentObjNum;
            p.buildResources.currentArray  = p.buildResources.browsingTools.navigator.currentArrayNum;
            
            p.segmentViewer = improc2.thresholdGUI.SegmentViewer(p.buildResources);
            
            p.segmentViewer.arrayUpdate;            
            p.segmentViewer.draw();
            
            set(figH, 'CloseRequestFcn', @(varargin) p.figureCloseRequest())
            p.figH = figH;
        end
    end
end

