classdef CentroidsListBoxSubsystem < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        centroidListBoxController
        centroidsFilter
        filterBoundsGUIHandles
        channelNames
    end
    
    methods
        function p = CentroidsListBoxSubsystem(centroidListBoxController, ...
                centroidsFilter)
            p.centroidListBoxController = centroidListBoxController;
            p.centroidsFilter = centroidsFilter;
            p.channelNames = centroidsFilter.channelNames;
        end
        
        function activateLaunchFilterBoundsGUIButton(p, uihandle)
            set(uihandle, 'callback', @(varargin) p.launchFilterGUI())
        end
        
        % untested
        function draw(p)
            p.centroidListBoxController.draw();
        end
        
        function setChannel(p, channelName)
            p.centroidListBoxController.setChannel(channelName);
        end
        
        function launchFilterGUI(p)
            if ~isempty(p.filterBoundsGUIHandles) && ...
                    ishandle(p.filterBoundsGUIHandles.figH)
                figure(p.filterBoundsGUIHandles.figH)
            else
                p.filterBoundsGUIHandles = dentist.createAndLayOutFilterGUI(p.channelNames);
                p.wireFilterBoundsGUI();
            end
        end
        
        function wireFilterBoundsGUI(p)
            p.centroidsFilter.attachLowerAndUpperBoundUIControls(...
                p.filterBoundsGUIHandles.leftNumBoxes, ...
                p.filterBoundsGUIHandles.rightNumBoxes)
            set(p.filterBoundsGUIHandles.applyFilter, ...
                'Callback', @(varargin) p.centroidListBoxController.setToUseFilter())
        end
    end
    
end

