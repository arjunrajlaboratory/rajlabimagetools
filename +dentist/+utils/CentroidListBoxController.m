classdef CentroidListBoxController < handle
    %UNTITLED14 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        spotsAndCentroids
        centroidSelectionResponder
        centroidsFilter
        channelHolder
        listBoxH
        numSpotsForItem
        centroidIndexForItem
        applyFilterFlag = false;
        useOrIgnoreFilterUI;
    end
    
    methods
        
        function p = CentroidListBoxController(listBoxH, ...
                centroidSelectionResponder, ...
                spotsAndCentroids, channelHolder)
            p.listBoxH = listBoxH;
            p.centroidSelectionResponder = centroidSelectionResponder;
            p.spotsAndCentroids = spotsAndCentroids;
            p.channelHolder = channelHolder;
            p.draw();
            set(p.listBoxH, 'Callback', @p.listBoxCallBack);
        end
        
        function attachCentroidsFilter(p, centroidsFilter)
            p.centroidsFilter = centroidsFilter;
        end
        
        function setToUseFilter(p)
            p.applyFilterFlag = true;
            p.draw();
            p.syncWithUseOrIgnoreFilterUI();
        end
        
        function setToIgnoreFilter(p)
            p.applyFilterFlag = false;
            p.draw();
            p.syncWithUseOrIgnoreFilterUI();
        end
        
        function attachUseOrIgnoreFilterUIControl(p, uihandle)
            p.useOrIgnoreFilterUI = uihandle;
            set(p.useOrIgnoreFilterUI, 'Max', true, 'Min', false);
            set(p.useOrIgnoreFilterUI, 'Value', p.applyFilterFlag);
            set(p.useOrIgnoreFilterUI, 'Callback', @p.useOrIgnoreFilterUICallback)
        end
        
        
        function syncWithUseOrIgnoreFilterUI(p)
            if ishandle(p.useOrIgnoreFilterUI)
                set(p.useOrIgnoreFilterUI, 'Value', p.applyFilterFlag)
            end
        end
        
        function useOrIgnoreFilterUICallback(p, hObject, eventdata)
            useFilter = get(p.useOrIgnoreFilterUI, 'Value');
            if useFilter
                p.setToUseFilter();
            else
                p.setToIgnoreFilter();
            end
        end
        
        function draw(p)
            p.prepareCentroidsList()
            %set(p.listBoxH, 'Value', 1);
            set(p.listBoxH, 'String', p.numSpotsForItem);
        end
        
        function listBoxCallBack(p, varargin)
            selectedItem = get(p.listBoxH, 'Value');
            selectedCentroidIndex =  p.centroidIndexForItem(selectedItem);
            p.centroidSelectionResponder.selectCentroid(selectedCentroidIndex);
        end
    end
    
    methods (Access = private)
        function prepareCentroidsList(p)
            
            if ~isempty(p.centroidIndexForItem)
                prevCentroid = p.centroidIndexForItem(p.listBoxH.Value);
            else
                prevCentroid = [];
            end
            
            channelName = p.channelHolder.getChannelName();
            
            
            numSpotsForCentroids = p.spotsAndCentroids.getNumSpotsForCentroids(channelName);
            if p.applyFilterFlag && ~isempty(p.centroidsFilter)
                centroidIndices = p.centroidsFilter.getPassingCentroidIndices(p.spotsAndCentroids);
                numSpotsForCentroids = numSpotsForCentroids(centroidIndices);
            else
                centroidIndices = 1:length(numSpotsForCentroids);
            end
            [numSpotsSorted, orderingPermutation] = sort(numSpotsForCentroids, 'descend');
            reorderedCentroidIndices = centroidIndices(orderingPermutation);
            p.numSpotsForItem = numSpotsSorted;
            p.centroidIndexForItem = reorderedCentroidIndices;
            
            if ~isempty(prevCentroid)
                p.listBoxH.Value = find(reorderedCentroidIndices==prevCentroid);
            else
                p.listBoxH.Value = 1;
            end
        end
    end
    
end

