classdef ColoringAndThumbnailSettings < handle
    
    properties (Access = private)
        numSpotsToColorTranslators
        thumbnailMakers
        actionsOnSettingsChange
        channelHolder
    end
    
    methods
        function p = ColoringAndThumbnailSettings(...
                numSpotsToColorTranslators, thumbnailMakers, channelHolder)
            p.numSpotsToColorTranslators = numSpotsToColorTranslators;
            p.thumbnailMakers = thumbnailMakers;
            p.channelHolder = channelHolder;
            p.actionsOnSettingsChange = improc2.utils.DependencyRunner();
        end
        
        function setNumSpotsScalingFunction(p, funcHandle, channelName)
            if nargin < 3
                channelName = p.channelHolder.getChannelName();
            end
            numSpotsToColorTranslator = ...
                p.numSpotsToColorTranslators.getByChannelName(channelName);
            numSpotsToColorTranslator.setScalingFunction(funcHandle)
            p.doAfterSettingsUpdate(channelName)
        end
        
        function setNumSpotsColorMap(p, colormap, channelName)
            if nargin < 3
                channelName = p.channelHolder.getChannelName();
            end
            numSpotsToColorTranslator = ...
                p.numSpotsToColorTranslators.getByChannelName(channelName);
            numSpotsToColorTranslator.setColorMap(colormap)
            p.doAfterSettingsUpdate(channelName)
        end
        
        function prioritizeHighExpressers(p, channelName)
            if nargin < 2
                channelName = p.channelHolder.getChannelName();
            end
            thumbnailMaker = p.thumbnailMakers.getByChannelName(channelName);
            thumbnailMaker.prioritizeHighExpressers()
            p.doAfterSettingsUpdate(channelName)
        end
        
        function prioritizeLowExpressers(p, channelName)
            if nargin < 2
                channelName = p.channelHolder.getChannelName();
            end
            thumbnailMaker = p.thumbnailMakers.getByChannelName(channelName);
            thumbnailMaker.prioritizeLowExpressers()
            p.doAfterSettingsUpdate(channelName)
        end
        
        function addActionOnSettingsChange(p, handleToObject, funcToRunOnIt)
            p.actionsOnSettingsChange.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
    methods (Access = private)
        function doAfterSettingsUpdate(p, channelName)
            thumbnailMaker = p.thumbnailMakers.getByChannelName(channelName);
            thumbnailMaker.makeAndStore();
            p.actionsOnSettingsChange.runDependencies();
        end
    end
end

