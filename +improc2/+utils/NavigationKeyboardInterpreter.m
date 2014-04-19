classdef NavigationKeyboardInterpreter < handle
    
    properties (Access = private)
        navigator
        channelSwitcher
        arrayOfStringComparable = {};
        arrayOfActionOnMatch = {};
    end
    
    methods
        function p = NavigationKeyboardInterpreter(navigator, channelSwitcher)
            p.navigator = navigator;
            p.channelSwitcher = channelSwitcher;
        end
        
        function addKeyPressCommand(p, somethingToStrcmpKeyTo, zeroArgFuncToExecuteOnMatch)
            assert(ischar(somethingToStrcmpKeyTo) || ...
                (iscell(somethingToStrcmpKeyTo) && all(cellfun(@ischar, somethingToStrcmpKeyTo))), ...
                'improc2:BadArguments', 'first argument must be a string or cell array of strings');
            assert(isa(zeroArgFuncToExecuteOnMatch, 'function_handle'), ...
                'improc2:BadArguments', 'second argument must be a function handle')
            p.arrayOfStringComparable = [p.arrayOfStringComparable, {somethingToStrcmpKeyTo}];
            p.arrayOfActionOnMatch = [p.arrayOfActionOnMatch, {zeroArgFuncToExecuteOnMatch}];
        end
        
        function keyPressCallBackFunc(p, src, event)
            k = event.Key;
            if any(strcmp(k,{'rightarrow','d','D'}))
                p.navigator.tryToGoToNextObj();
            elseif any(strcmp(k,{'leftarrow','a','A'}))
                p.navigator.tryToGoToPrevObj();
            elseif any(strcmp(k,{'e','E'}))
                p.goToNextChannel();
            elseif any(strcmp(k,{'q','Q'}))
                p.goToPrevChannel();
            else
                p.matchOptionallyDefinedKeyAction(k)
            end
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
    methods (Access = private)
        function matchOptionallyDefinedKeyAction(p, key)
            for i = 1:length(p.arrayOfStringComparable)
                toMatch = p.arrayOfStringComparable{i};
                actionOnMatch = p.arrayOfActionOnMatch{i};
                if any(strcmp(key, toMatch))
                    actionOnMatch();
                    break
                end
            end
        end
        
        
        function goToNextChannel(p)
            index = p.getCurrentChannelIndex();
            p.goToChannelAtIndex(index + 1)
        end
        
        function goToPrevChannel(p)
            index = p.getCurrentChannelIndex();
            p.goToChannelAtIndex(index - 1)
        end
        
        function index = getCurrentChannelIndex(p)
            currentChannel = p.channelSwitcher.getChannelName();
            index = find(strcmp(currentChannel, p.channelSwitcher.channelNames));
        end
        
        function goToChannelAtIndex(p, index)
            numOfChannels = length(p.channelSwitcher.channelNames);
            indexAfterWrappingAround = 1 + mod(index - 1, numOfChannels);
            p.channelSwitcher.setChannelName(...
                p.channelSwitcher.channelNames{indexAfterWrappingAround});
        end
    end
end

