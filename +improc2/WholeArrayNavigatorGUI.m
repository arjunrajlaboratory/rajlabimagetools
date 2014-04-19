classdef WholeArrayNavigatorGUI < handle
    
    properties (Access = private)
        navigator
        navigationPanel
        UIcontrols
    end
    
    methods
        function p = WholeArrayNavigatorGUI(navigator)
            p.navigator = navigator;
            p.makeNavigationPanel()
            p.navigator.addActionAfterMovingToNewArray(p, @update)
            p.update()
        end
        
        function update(p)
            set(p.UIcontrols.goToArray, 'String', ...
                num2str(p.navigator.currentArrayNum))
        end
        
        function delete(p)
            if ishandle(p.navigationPanel)
                delete(p.navigationPanel)
            end
        end
    end
    
    methods (Access = private)
        function makeNavigationPanel(p)
            p.navigationPanel = figure('Position',[250 100 270 100],...
                'NumberTitle','off',...
                'Name','Navigation',...
                'Resize','on',...
                'Toolbar','none',...
                'MenuBar','none',...
                'Visible','off');
            set(p.navigationPanel, 'Visible', 'on')
            set(p.navigationPanel, 'CloseRequestFcn', @p.onFigureClose);
            p.addGUIElements();
        end
        
        function onFigureClose(p, varargin)
            delete(p)
        end
        

        
        function goToArrayCallBack(p)
            try
                requestedArray = str2num(get(p.UIcontrols.goToArray, 'String'));
            catch err
                p.update()
                rethrow(err)
            end
            p.goToArray(requestedArray);
        end
        
        function goToNextArrayCallBack(p)
            currentArray = p.navigator.currentArrayNum;
            requestedArray = min(currentArray + 1, p.navigator.numberOfArrays); 
            p.goToArray(requestedArray);
        end
        
        function goToPrevArrayCallBack(p)
            currentArray = p.navigator.currentArrayNum;
            requestedArray = max(currentArray - 1, 1); 
            p.goToArray(requestedArray);
        end
        
        function goToArray(p, requestedArray)
            try
                p.navigator.tryToGoToArray(requestedArray);
            catch err
                p.update()
                rethrow(err)
            end
            p.update()
        end
        
        function addGUIElements(p)
            p.UIcontrols.prevArray = uicontrol('Parent',p.navigationPanel,...
                'Style','pushbutton',...
                'Callback', @(varargin) p.goToPrevArrayCallBack(),...
                'Units','normalized',...
                'Position',[0.025 0.622 0.416 0.300],...
                'String','Prev',...
                'FontSize',12,'FontWeight','bold');
            p.UIcontrols.nextArray = uicontrol('Parent',p.navigationPanel,...
                'Style','pushbutton',...
                'Callback',@(varargin) p.goToNextArrayCallBack(),...
                'Units','normalized',...
                'Position',[0.525 0.622 0.416 0.300],...
                'String','Next',...
                'FontSize',12,'FontWeight','bold');
            p.UIcontrols.fileLabel = uicontrol('Parent', p.navigationPanel, ...
                'Style','text',...
                'String','Array:',...
                'Units', 'normalized', ...
                'Position', [0.025 0.1 0.216 0.3], ...
                'FontSize', 16, 'FontWeight', 'bold');
            p.UIcontrols.goToArray = uicontrol('Parent',p.navigationPanel,...
                'Style','edit',...
                'Callback', @(varargin) p.goToArrayCallBack(),...
                'Units','normalized',...
                'Position',[0.275 0.1 0.216 0.300],...
                'FontSize',12);
        end
    end 
    
end

