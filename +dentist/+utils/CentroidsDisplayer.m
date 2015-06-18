classdef CentroidsDisplayer < dentist.utils.AbstractDisplayer
    %UNTITLED19 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess =  private, SetAccess = private)
        centroidsAndNumSpotsSource
        axH
        displayedH
        parametersHolder
        viewportHolder
        numSpotsToColorTranslators
        channelHolder
    end
    
    
    methods
        function p = CentroidsDisplayer(axH, resources)
            p.axH = axH;
            p.centroidsAndNumSpotsSource = resources.centroidsAndNumSpotsSource;
            p.parametersHolder = resources.parametersHolder;
            p.viewportHolder = resources.viewportHolder;
            p.numSpotsToColorTranslators = resources.numSpotsToColorTranslators;
            p.channelHolder = resources.channelHolder;
        end
        
        
        function draw(p)
            p.clearGraphics();
            centroids = p.centroidsAndNumSpotsSource.getCentroids();
            viewport = p.viewportHolder.getViewport();

            [centroidsInViewport, inViewportIndices] = ...
                dentist.utils.filterPointsByViewport(centroids, viewport);
            
            % this helps it load faster.
            centroidsInViewport.xPositions = centroidsInViewport.xPositions*0.1;
            centroidsInViewport.yPositions = centroidsInViewport.yPositions*0.1;
            
            channelName = p.channelHolder.getChannelName();
            numSpots = p.centroidsAndNumSpotsSource.getNumSpotsForCentroids(channelName);
            numSpotsToColorTranslator = ...
                p.numSpotsToColorTranslators.getByChannelName(channelName);
            rgbOfAllCentroids = numSpotsToColorTranslator.translateToRGB(numSpots);
            rgbOfCentroidsInViewport = rgbOfAllCentroids(inViewportIndices, :);
            
            switch p.parametersHolder.get('spotsOrCircles')
                case 'spots'
                    p.drawPointsAtCentroids(centroidsInViewport, rgbOfCentroidsInViewport)
                case 'circles'
                    p.drawCirclesAtCentroids(centroidsInViewport, rgbOfCentroidsInViewport)
            end
        end
        
        function deactivate(p)
            p.clearGraphics();
        end
        
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ~isempty(p.displayedH) && ishandle(p.displayedH(1))
                delete(p.displayedH);
            end
            p.displayedH = [];
        end
        
        
        function drawPointsAtCentroids(p, centroids, rgbColors)
            spotSize = 50;
            hold(p.axH, 'on')
            p.displayedH = scatter(p.axH,...
                centroids.xPositions, centroids.yPositions, ...
                spotSize, rgbColors, 'fill', 'o', 'HitTest', 'off');
            hold(p.axH, 'off')
        end
        
        function drawCirclesAtCentroids(p, centroids, rgbColors)
            
            circleRadius = p.parametersHolder.get('circleRadius');
            
            for i = 1:length(centroids)
                x = round(centroids.xPositions(i));
                y = round(centroids.yPositions(i));
                th = 0:pi/50:2*pi;
                xunit = circleRadius * cos(th) + x;
                yunit = circleRadius * sin(th) + y;
                color = rgbColors(i,:);
                h = line(xunit, yunit, 'Color', color, 'Parent', p.axH, 'LineWidth', 3);
                p.displayedH = [p.displayedH, h];
            end
        end
    end
    
end

