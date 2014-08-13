classdef ChannelDropDown
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dropDownH
        imageProvider
        axesManager
        foundChannels
    end
    
    methods
        function p = ChannelDropDown(dropDownH, foundChannels, imageProvider, axesManager)
            p.dropDownH = dropDownH;
            p.imageProvider = imageProvider;
            p.axesManager = axesManager;
            p.foundChannels = foundChannels;
            set(dropDownH, 'Callback',{@dropDownChangedCallback,p});
            set(dropDownH, 'String',p.foundChannels);
        end
        function dropDownChangedCallback(hObject, eventData, p)
            chanIndex = get(hObject,'Value');
            p.imageProvider.setChanIndex(chanIndex);
            p.axesManager.displayImage();
            p.axesManager.setFocusToFigure();
        end
    end
    
end

