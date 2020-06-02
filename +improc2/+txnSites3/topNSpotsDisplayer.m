classdef topNSpotsDisplayer <  handle
    
    properties (Access = private)
        axH
%         spotsProvider
        channels
        nirSpotsHolder
        alexaSpotsHolder
        cySpotsHolder
        tmrSpotsHolder
        gfpSpotsHolder
        objectHandle
        paramsForComposite
        lineHandle
        nirN
        alexaN
        cyN
        tmrN
        gfpN
    end
    
    methods
%         function p = topNSpotsDisplayer(axH, nirSpotsHolder, alexaSpotsHolder, cySpotsHolder, tmrSpotsHolder, gfpSpotsHolder, paramsForComposite)
        function p = topNSpotsDisplayer(axH, objectHandle, paramsForComposite, channels)
            p.axH = axH;
            p.objectHandle = objectHandle;
%             p.nirSpotsHolder = nirSpotsHolder;
%             p.alexaSpotsHolder = alexaSpotsHolder;
%             p.cySpotsHolder = cySpotsHolder;
%             p.tmrSpotsHolder = tmrSpotsHolder;
%             p.gfpSpotsHolder = gfpSpotsHolder;
            p.paramsForComposite = paramsForComposite;
            p.channels = channels;

            
        end
        function draw(p)
            p.clearGraphics()
            
            if max(ismember(p.channels, 'nir'))
            p.nirSpotsHolder = p.objectHandle.getData('nir:Fitted').getFittedSpots();
            end
            if max(ismember(p.channels, 'alexa'))
            p.alexaSpotsHolder = p.objectHandle.getData('alexa:Fitted').getFittedSpots();
            end
            if max(ismember(p.channels, 'tmr'))
            p.tmrSpotsHolder = p.objectHandle.getData('tmr:Fitted').getFittedSpots();
            end
            if max(ismember(p.channels, 'cy'))
            p.cySpotsHolder = p.objectHandle.getData('cy:Fitted').getFittedSpots();
            end
            if max(ismember(p.channels, 'gfp'))
            p.gfpSpotsHolder = p.objectHandle.getData('gfp:Fitted').getFittedSpots();
            end
            
            
%             p.cySpotsHolder = cySpotsHolder;
%             p.tmrSpotsHolder = tmrSpotsHolder;
%             p.alexaSpotsHolder = alexaSpotsHolder;

            p.nirN = p.paramsForComposite.getValue('circleNir');
            p.alexaN = p.paramsForComposite.getValue('circleAlexa');
            p.cyN = p.paramsForComposite.getValue('circleCy');
            p.tmrN = p.paramsForComposite.getValue('circleTmr');
            p.gfpN = p.paramsForComposite.getValue('circleGfp');
%             [Xs, Ys] = p.getTopNSpotPositions();

%             [X, Y, Z, parentNodeName] = p.clickedSpotsCollection.getNearbySpotCoordinates();
% channels = {'alexa', 'cy', 'tmr'};
% parentNodeNames = {'alexa:Fitted','cy:Fitted','tmr:Fitted'};
            for m = 1:length(p.channels)
                parentNodeNames = [p.channels{m} ':Fitted'];
                parentNodeNamesToColors.parentNodeNames = {'alexa:Fitted', 'cy:Fitted', 'tmr:Fitted', 'gfp:Fitted', 'nir:Fitted'};
%                 parentNodeNamesToColors.colors = {'r', 'w', 'g', 'g', 'p'};
                parentNodeNamesToColors.colors = {p.paramsForComposite.getValue('colorAlexa'), p.paramsForComposite.getValue('colorCy'), p.paramsForComposite.getValue('colorTmr'), p.paramsForComposite.getValue('colorGfp'), p.paramsForComposite.getValue('colorNir')};
                idk = ismember(parentNodeNamesToColors.parentNodeNames,parentNodeNames);
                channelSpotHolder = [p.channels{m} 'SpotsHolder'];
                channelN = [p.channels{m} 'N'];
                intensities = [p.(channelSpotHolder).amplitude];
                topn = maxk(intensities, p.(channelN));
                ids = ismember(intensities, topn);
                Xs = [p.(channelSpotHolder).xCenter];
                Ys = [p.(channelSpotHolder).yCenter];
                topXs = Xs(ids);
                topYs = Ys(ids);
                p.lineHandle = line(topXs, topYs, ...
                        'LineStyle', 'none', ...
                        'Marker','o', 'MarkerEdgeColor', parentNodeNamesToColors.colors{idk}, ...
                        'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 12);

            end
            

%             
%             for k = 1:length(parentNodeName)
%                 idy = ismember(parentNodeNamesToColors.parentNodeNames,parentNodeName{k});
%                 p.lineHandle = line(X(k), Y(k), ...
%                     'LineStyle', 'none', ...
%                     'Marker','o', 'MarkerEdgeColor', parentNodeNamesToColors.colors{idy}, ...
%                     'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 14);
%             end
%             
%             p.lineHandle = line(topXs, topYs, ...
%                     'LineStyle', 'none', ...
%                     'Marker','o', 'MarkerEdgeColor', 'w', ...
%                     'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 12);

        end
        function deactivate(p)
            p.clearGraphics()
        end
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ~isempty(p.lineHandle) && ishandle(p.lineHandle)
                delete(p.lineHandle)
            end
        end
    end
    
end

