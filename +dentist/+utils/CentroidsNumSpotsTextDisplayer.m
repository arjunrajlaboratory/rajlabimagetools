classdef CentroidsNumSpotsTextDisplayer < dentist.utils.AbstractDisplayer
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        centroidsAndNumSpotsSource
        axH
        channelHolder
        displayedTextH
        parametersHolder
        viewportHolder
    end
    
    
    
    methods
        function p = CentroidsNumSpotsTextDisplayer(axH, ...
                centroidsAndNumSpotsSource, channelHolder, parametersHolder, ...
                viewportHolder)
            p.axH = axH;
            p.centroidsAndNumSpotsSource = centroidsAndNumSpotsSource;
            p.channelHolder = channelHolder;
            p.parametersHolder = parametersHolder;
            p.viewportHolder = viewportHolder;
        end
        
        
        function draw(p)
            p.clearGraphics();
            
            viewport = p.viewportHolder.getViewport();
            channelName = p.channelHolder.getChannelName();
            
            centroids = p.centroidsAndNumSpotsSource.getCentroids();
            numSpots = p.centroidsAndNumSpotsSource.getNumSpotsForCentroids(channelName);
            [centroidsInViewport, indicesOfCentroidsInViewport] = ...
                dentist.utils.filterPointsByViewport(centroids, viewport);
            numSpotsInViewport = numSpots(indicesOfCentroidsInViewport);
            Xs = centroidsInViewport.xPositions + p.parametersHolder.get('xOffset');
            Ys = centroidsInViewport.yPositions + p.parametersHolder.get('yOffset');
            p.displayedTextH = text(Xs, Ys, num2cell(numSpotsInViewport), ...
                'FontSize', p.parametersHolder.get('FontSize'), ...
                'Color', [1 1 1], ...
                'Parent', p.axH, 'HitTest', 'off');
        end
        
        function deactivate(p)
            p.clearGraphics();
        end
        
        function clearGraphics(p)
            if ~isempty(p.displayedTextH) && ishandle(p.displayedTextH(1))
                delete(p.displayedTextH);
            end
        end
        
    end
    
end

