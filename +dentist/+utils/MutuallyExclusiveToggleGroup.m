classdef MutuallyExclusiveToggleGroup < handle
    
    properties (SetAccess = private, GetAccess = private)
        nameOfActiveButton;
        structOfButtonHandles;
    end
    properties (SetAccess = private, GetAccess = protected)
        buttonNames;
    end
    
    
    methods
        function p = MutuallyExclusiveToggleGroup(structOfButtonHandles)
            p.buttonNames = fields(structOfButtonHandles);
            p.structOfButtonHandles = structOfButtonHandles;
        end
        
        function initialize(p, startingButtonName)
            if nargin < 2
                startingButtonName = p.buttonNames{1};
            else
                assert(ismember(startingButtonName, p.buttonNames), ...
                    'specified starting button name unrecognized')
            end
            p.nameOfActiveButton = startingButtonName;
            p.doOnToggleTo(startingButtonName);
            p.setButtonCallbacks();
            p.syncWithUI();
        end
        
        function activateButton(p, buttonName)
            assert(ismember(buttonName, p.buttonNames), ...
                'improc2:BadArguments', ...
                'specified button name is not one of %s', improc2.utils.stringJoin(p.buttonNames(:)', ' or ')) 
            
            if ~strcmp(buttonName, p.nameOfActiveButton)
                p.doOnToggleOutOf(p.nameOfActiveButton)
                p.nameOfActiveButton = buttonName;
                p.syncWithUI()
                p.doOnToggleTo(buttonName)
            else
                p.syncWithUI()
            end
        end
    end
    
    methods (Access = protected)
        function doOnToggleTo(p, buttonName)
            fprintf('Switched to %s!\n', buttonName);
        end
        
        function doOnToggleOutOf(p, buttonName)
            fprintf('Switched out from %s\n', buttonName);
        end
    end
    
    methods (Access = private)
        function setButtonCallbacks(p)
            for buttonIndex = 1:length(p.buttonNames)
                buttonName = p.buttonNames{buttonIndex};
                buttonH = p.structOfButtonHandles.(buttonName);
                set(buttonH, 'Callback', @(varargin) p.activateButton(buttonName))
            end
        end
        
        function syncWithUI(p)
            for buttonIndex = 1:length(p.buttonNames)
                buttonName = p.buttonNames{buttonIndex};
                buttonH = p.structOfButtonHandles.(buttonName);
                if strcmp(buttonName, p.nameOfActiveButton)
                    set(buttonH, 'Value', 1)
                else
                    set(buttonH, 'Value', 0)
                end
            end
        end
    end
    
end

