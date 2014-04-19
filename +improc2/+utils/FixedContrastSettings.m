classdef FixedContrastSettings < handle
    
    properties (Access = private)
        channelHolder
        scaledImageHolder
        saturationValues
        actionsAfterSettingsChange
    end
    
    properties (SetAccess = private)
        channelNames
    end
    
    methods
        function p = FixedContrastSettings(channelHolder, scaledImageHolder)
            p.channelHolder = channelHolder;
            p.scaledImageHolder = scaledImageHolder;
            p.saturationValues = dentist.utils.ChannelArray(channelHolder.channelNames);
            p.actionsAfterSettingsChange = improc2.utils.DependencyRunner();
        end
        
        function addActionAfterSettingsChange(p, handleToObject, funcToRunOnIt)
            p.actionsAfterSettingsChange.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        function setSaturationValue(p, value, channelName)
            if nargin < 3
                channelName = p.channelHolder.getChannelName();
            end
            assert(isnumeric(value) && isscalar(value), 'improc2:BadArguments', ...
                'Saturation value must be a scalar number')
            p.saturationValues = p.saturationValues.setByChannelName(value, channelName);
            p.actionsAfterSettingsChange.runDependencies();
        end
        
        function value = getSaturationValue(p)
            channelName = p.channelHolder.getChannelName();
            value = p.saturationValues.getByChannelName(channelName);
            if isempty(value)
                p.setSaturationValueToCurrentImage();
                value = p.saturationValues.getByChannelName(channelName);
            end
        end
        
        function setSaturationValueToCurrentImage(p)
            [~, minAndMaxInUnscaledIm] = p.scaledImageHolder.getImage();
            saturationValue = minAndMaxInUnscaledIm(2);
            p.setSaturationValue(saturationValue)
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
end

