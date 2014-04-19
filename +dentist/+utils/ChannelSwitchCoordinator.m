classdef ChannelSwitchCoordinator < handle
    
    properties (Access = private)
        channelNameFactor
        actionsAfterChannelSwitch
        channelUIhandle
    end
    
    properties (Dependent = true)
        channelNames
    end
    
    methods
        function p = ChannelSwitchCoordinator(channelNames)
            p.channelNameFactor = improc2.TypeCheckedFactor(channelNames);
            p.actionsAfterChannelSwitch = improc2.utils.DependencyRunner();
        end
        
        function addActionAfterChannelSwitch(p, handleToObject, funcToRunOnIt)
            p.actionsAfterChannelSwitch.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        function setChannelName(p, channelName)
            p.channelNameFactor.value = channelName;
            p.actionsAfterChannelSwitch.runDependencies();
            p.syncWithUI();
        end
        
        function channelName = getChannelName(p)
            channelName = p.channelNameFactor.value;
        end
        
        function channelNames = get.channelNames(p)
            channelNames = p.channelNameFactor.choices;
        end
        
        function attachUIControl(p, popupUIhandle)
            p.channelUIhandle = popupUIhandle;
            set(p.channelUIhandle, 'String', p.channelNames)
            p.setUIValue()
            set(p.channelUIhandle, 'Callback', @(varargin) p.callback())
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
    methods (Access = private)
        function syncWithUI(p)
            if ~isempty(p.channelUIhandle) && ishandle(p.channelUIhandle)
                p.setUIValue()
            end
        end
        
        function setUIValue(p)
            set(p.channelUIhandle, 'Value', ...
                find(strcmp(p.getChannelName(), p.channelNames)))
        end
        
        function callback(p)
            chanIndex = get(p.channelUIhandle, 'Value');
            p.setChannelName(p.channelNames{chanIndex});
        end
    end
end

