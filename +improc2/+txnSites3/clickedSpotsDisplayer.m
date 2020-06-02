classdef clickedSpotsDisplayer < handle
%Draws a circle on the selected transcription sites on the image. Currently
%only draws sites at Exon Coordinates - Considered drawing exon and intron,
%but it looked kinda messy
properties
        axH
        clickedSpotsCollection
        lineHandle
        currPoints
        newPoints
        paramsForComposite
end
    

    methods
        function p = clickedSpotsDisplayer(axH, clickedSpotsCollection, paramsForComposite)
            p.axH = axH;
            p.clickedSpotsCollection = clickedSpotsCollection;
            p.paramsForComposite = paramsForComposite;
        end
        
        function draw(p)
            p.clearGraphics()
            
%             [Xs, Ys] = p.clickedSpotsCollection.getOtherCoordsToDisplayOnInit();
%             p.lineHandle = line(Xs, Ys, ...
%                 'LineStyle', 'none', ...
%                 'Marker','o', 'MarkerEdgeColor', 'r', ...
%                 'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 14);
%             
            [Xs, Ys] = p.clickedSpotsCollection.getClickedSpotCoordinates();
            p.lineHandle = line(Xs, Ys, ...
                'LineStyle', 'none', ...
                'Marker','o', 'MarkerEdgeColor', 'b', ...
                'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 14);
            
            [X, Y, Z, parentNodeName] = p.clickedSpotsCollection.getNearbySpotCoordinates();
            
            parentNodeNamesToColors.parentNodeNames = {'alexa:Fitted', 'cy:Fitted', 'tmr:Fitted', 'gfp:Fitted', 'nir:Fitted'};
%             parentNodeNamesToColors.colors = {'r', 'w', 'g', 'g', 'g'};
            parentNodeNamesToColors.colors = {p.paramsForComposite.getValue('colorAlexa'), p.paramsForComposite.getValue('colorCy'), p.paramsForComposite.getValue('colorTmr'), p.paramsForComposite.getValue('colorGfp'), p.paramsForComposite.getValue('colorNir')};
            
            for k = 1:length(parentNodeName)
                idy = ismember(parentNodeNamesToColors.parentNodeNames,parentNodeName{k});
                p.lineHandle = line(X(k), Y(k), ...
                    'LineStyle', 'none', ...
                    'Marker','o', 'MarkerEdgeColor', parentNodeNamesToColors.colors{idy}, ...
                    'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 14);
            end
            

%             objectHandle = p.buildResources.objectHandle;
%             temp = struct();
%             temp.xCoord = objectHandle.getData('ManuallyClickedSpots').ClickedXs;
%             temp.yCoord = objectHandle.getData('ManuallyClickedSpots').ClickedYs;
%             temp.pointID = objectHandle.getData('ManuallyClickedSpots').pointID;
            
            
         
    
            
        end

       function out = drawPoints(p)
            [Xs, Ys] = p.clickedSpotsCollection.getClickedSpotCoordinates();
%             p.deleteAllPoints();
            p.currPoints = images.roi.Point;
            for i = 1:length(Xs)
                p.currPoints(i) = drawpoint(p.axH, 'Position',[Xs(i) Ys(i)],...
                'Color','b','SelectedColor','c','UserData', i);
            addlistener(p.currPoints(i),'ROIMoved',@p.pointMoved);
            
            end
            out = p.currPoints;
       end

       
       function pointMoved(p, src, eventData)
            fprintf('Moving spot %s', sprintf([num2str(src.UserData), '\n']));
            %fprintf('Moving\n');
%             objectHandle = p.buildResources.objectHandle;
%             channels = p.buildResources.channels;
% 
%                 n_channels = length(channels);
% 
%                 if n_channels == 1
%                     p.clickedSpotsCollection = clickedSpotsCollection_one(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
%                 elseif n_channels == 2
%                     p.clickedSpotsCollection = clickedSpotsCollection_two(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
%                 elseif n_channels == 3
%                     p.clickedSpotsCollection = clickedSpotsCollection_three(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
%                 elseif n_channels == 4
%                     p.clickedSpotsCollection = clickedSpotsCollection_four(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
%                 elseif n_channels == 5
%                     p.clickedSpotsCollection = clickedSpotsCollection_five(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
%                 end
                
            p.clickedSpotsCollection.moveClickedSpot(src.UserData, eventData.CurrentPosition(1), eventData.CurrentPosition(2));
%             p.pointTableHandle.allPoints(p.pointTableHandle.allPoints.pointID == src.UserData,:)
%             p.drawLines();
            p.deleteAllPoints();
            p.currPoints = p.drawPoints();
            p.draw();
  
       end
        
       
       function deletePoint(p, pt)
%                        pointID = src.UserData;
%             p.pointTableHandle.removePoints(pointID);
            if ~islogical(pt)
                delete(pt);
            end
       end
       
       
       function deleteAllPoints(p)
           
           if ~isempty(p.currPoints)
            for f = 1:length(p.currPoints)
                pt = p.currPoints(f);
                p.deletePoint(pt)
                
                
%                 p.currPoints(f) = [];
%                 clear p.currPoints(f);
%                 p.currPoints = isvalid(p.currPoints);
            end
%             clear p.currPoints;
%             for i = 1:length(p.newPoints)
%                 pt = p.newPoints(i);
%                 p.deletePoint(pt,[])
%             end
%             p.currPoints = [];
%             p.newPoints = p.newPoints(isvalid(p.currPoints));
           else
           end
           
       end
              
       
       
        function deactivate(p)
            p.clearGraphics();
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

