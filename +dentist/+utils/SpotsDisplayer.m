classdef SpotsDisplayer < dentist.utils.AbstractDisplayer
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private, SetAccess = private)
        axH
        spotsAndCentroidsSource
        channelHolder
        displayedH
        colorCycler
        viewportHolder
    end
    
    
    methods
        function p = SpotsDisplayer(axH, spotsAndCentroidsSource, channelHolder, viewportHolder)
            p.axH = axH;
            p.spotsAndCentroidsSource = spotsAndCentroidsSource;
            p.channelHolder = channelHolder;
            p.viewportHolder = viewportHolder;
            p.colorCycler = dentist.utils.makeColorCycler();
        end
        
        function draw(p)
            p.clearGraphics();
            
            viewport = p.viewportHolder.getViewport();
            channelName = p.channelHolder.getChannelName();
            
            centroids = p.spotsAndCentroidsSource.getCentroids();
            [~, indicesOfCentroidsInViewport] = ...
                dentist.utils.filterPointsByViewport(centroids, viewport);
            
            spots = p.spotsAndCentroidsSource.getSpots(channelName);
            spotToCentroidMapping = ...
                p.spotsAndCentroidsSource.getSpotToCentroidMapping(channelName);
            
            p.colorCycler.reset();
            for i = 1:length(indicesOfCentroidsInViewport)
                indexOfCentroid = indicesOfCentroidsInViewport(i);
                spotsAssignedToCentroid = spots.subsetByIndices(...
                    find(spotToCentroidMapping == indexOfCentroid));
                h = line(spotsAssignedToCentroid.xPositions, ...
                    spotsAssignedToCentroid.yPositions,...
                    'LineStyle', 'none', ...
                    'Marker','o', 'MarkerEdgeColor', p.colorCycler.next(), ...
                    'Parent', p.axH, 'HitTest', 'off');
                if isempty(p.displayedH)
                    p.displayedH = h;
                else
                    % if you don't guard against concatenating two empty
                    % matrices, can get the warning
                    % "Concatenation including empty arrays will require
                    % all arrays to have the same number of rows in a
                    % future release." Can't figure out how to reproduce
                    % warning - GPN
                    p.displayedH = [p.displayedH, h];
                end
            end
        end
        
        function deactivate(p)
            p.clearGraphics();
        end 
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ~isempty(p.displayedH) && ishandle(p.displayedH(1))
                delete(p.displayedH)
                p.displayedH = [];
            end
        end
    end
    
end

