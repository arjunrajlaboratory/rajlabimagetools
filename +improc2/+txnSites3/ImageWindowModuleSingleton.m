classdef ImageWindowModuleSingleton < handle
    
    properties (Access = private)
%         newPoints
        currPoints
        clickedSpotsCollection
        objectHandle
        imageWindowModule
        figH
        buildResources = struct();
        keyboardInterpreter
    end
    
    methods
        function p = ImageWindowModuleSingleton(resources)
            p.buildResources.rnaScaledImageHolder = resources.rnaScaledImageHolder;
            p.buildResources.objectHandle = resources.objectHandle;
            p.buildResources.rnaProcessorDataHolder = resources.rnaProcessorDataHolder;
            p.buildResources.viewportHolder = resources.viewportHolder;
            p.buildResources.saturationValuesHolder = resources.saturationValuesHolder;
            p.buildResources.paramsForComposite = resources.paramsForComposite;
            p.buildResources.navigator = resources.navigator;
            p.buildResources.navgui = resources.gui;
            p.buildResources.channels = resources.channels;
            p.buildResources.nodeName = resources.nodeName;            
            p.keyboardInterpreter = resources.keyboardInterpreter;
        end
        function launchGUI(p)
            if ~isempty(p.imageWindowModule) && isvalid(p.imageWindowModule)
                figure(p.figH)
            else
                p.buildGUI()
                keyboardInterpreter = p.keyboardInterpreter;
                set(p.figH, 'WindowKeyPressFcn', ...
                    @keyboardInterpreter.keyPressCallBackFunc)
                keyboardInterpreter.addKeyPressCommand('alt',@(varargin) p.addPointsButtonPushed);
            end
        end

%         function toggleSpots(p)
%             if isvalid(p.imageWindowModule)
%                 p.imageWindowModule.toggleSpots()
%             end
%         end

        
        function updateIfActive(p)
            if isvalid(p.imageWindowModule)
                p.imageWindowModule.draw()
            end
        end
    end
    
    methods (Access = private)
        function figureCloseRequest(p, varargin)
            delete(p.imageWindowModule)
            delete(p.figH);
        end
    
       
        function buildGUI(p)
            gui = improc2.txnSites3.layOutImageInspectionGUI();
            p.figH = gui.figH;
            
            forContraster = struct();
            forContraster.rnaProcessorDataHolder    = p.buildResources.rnaProcessorDataHolder;
            forContraster.saturationValuesHolder    = p.buildResources.saturationValuesHolder;
            forContraster.gui = gui;
            imageContrastModule = improc2.txnSites3.RNAImageContrastModule(...
                forContraster);
            
            forImageWindow = struct();
            forImageWindow.rnaScaledImageHolder      = p.buildResources.rnaScaledImageHolder;
            forImageWindow.objectHandle              = p.buildResources.objectHandle;
            forImageWindow.rnaProcessorDataHolder    = p.buildResources.rnaProcessorDataHolder;
            forImageWindow.viewportHolder            = p.buildResources.viewportHolder;
            forImageWindow.gui                          = gui;
            forImageWindow.imageContrastModule          = imageContrastModule;
            forImageWindow.paramsForComposite        = p.buildResources.paramsForComposite;
            forImageWindow.navgui                    = p.buildResources.navgui;
            forImageWindow.navigator                 = p.buildResources.navigator;
            forImageWindow.channels                  = p.buildResources.channels;
            forImageWindow.nodeName                  = p.buildResources.nodeName;
            
            set(gui.addPointsButtonHandle, 'Callback', @(varargin) p.addPointsButtonPushed)
%             set(gui.deletePointsButtonHandle, 'Callback', @(varargin) p.deleteButtonPushed)
            set(gui.deletePointsButtonHandle, 'Callback', @(varargin) p.deleteLastButtonPushed)
            set(gui.deselectAllButtonHandle, 'Callback', @(varargin) p.deselectAllButtonPushed)
            
            
            p.imageWindowModule = improc2.txnSites3.ImageWindowModule(forImageWindow);
            p.currPoints = p.imageWindowModule.currPoints;
            
            
%             objectHandle = p.buildResources.objectHandle;
%             temp = struct();
%             temp.xCoord = objectHandle.getData('ManuallyClickedSpots').ClickedXs;
%             temp.yCoord = objectHandle.getData('ManuallyClickedSpots').ClickedYs;
%             temp.pointID = objectHandle.getData('ManuallyClickedSpots').pointID;
%             
%             
%             p.currPoints = images.roi.Point;
% 
%             for i = 1:length(temp.xCoord)
%                 p.currPoints(i) = drawpoint(gui.imgAx,'Position',[temp.xCoord(i) temp.yCoord(i)],...
%                 'Color','b','SelectedColor','c');
%                 p.currPoints(i).UserData = temp.pointID(i);
%                 addlistener(p.currPoints(i),'ROIMoved',@p.pointMoved);
%             end 
%             
%             
            
%             p.imageWindowModule.navigator.addActionBeforeMoveAttempt(p.imageWindowModule.clickedSpotsDisplayer, @deleteAllPoints);
            set(p.figH, 'CloseRequestFcn', @(varargin) p.figureCloseRequest())
        end

         function addPointsButtonPushed(p, src, eventdata)
                fprintf('you are now in add points mode!\n');
%                 p.currPoints = images.roi.Point;
                p.currPoints(end+1) = drawpoint(...
                    'Color','b','SelectedColor','c');
                x = p.currPoints(end).Position(1);
                y = p.currPoints(end).Position(2);
                p.currPoints(end).UserData = length(p.currPoints);
                
                objectHandle = p.buildResources.objectHandle;
                channels = p.buildResources.channels;
                
                
                n_channels = length(channels);

                if n_channels == 1
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_one(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                elseif n_channels == 2
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_two(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                elseif n_channels == 3
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_three(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                elseif n_channels == 4
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_four(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                elseif n_channels == 5
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_five(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                end
                
                
                p.clickedSpotsCollection.addClickedSpot(x, y);

                p.imageWindowModule.imgAreaDisplayer.draw();
                p.deleteNewPoints();
                
%                 pt = p.currPoints(end);
%                 delete(pt);
                
%                 p.imageWindowModule.clickedSpotsDisplayer.deleteAllPoints();
                p.currPoints = p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
%                 addlistener(p.currPoints(end),'ROIMoved',@p.pointMoved);
%                 navigator.addActionBeforeMoveAttempt(p.imageclickedSpotsDisplayerforImageWindow, @deleteAllPoints);
% 
%                 p.imageWindowModule.navigator.addActionBeforeMoveAttempt(p, @deleteNewPoints);
%                 p.imageWindowModule.navigator.addActionAfterMoveAttempt(p.imageWindowModule.clickedSpotsDisplayer, @drawPoints);
%                 p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
                %                 p.currPoints(end) = [];
%                 p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
%                 p.imageWindowModule.navigator.addActionBeforeMoveAttempt(p.imageWindowModule.clickedSpotsDisplayer, @deleteAllPoints);
%                 addlistener(p.currPoints(end),'ROIDeleted',@p.imageWindowModule.clickedSpotsDisplayer.deletAllPoints);
%                 delete(src);

                
         end
        
        function deleteNewPoints(p)
            for g = 1:length(p.currPoints)
            pt = p.currPoints(g);
            delete(pt);
            end
        end
 
%         function deleteButtonPushed(p, src, eventdata)
%             objectHandle = p.buildResources.objectHandle;
%             channels = p.buildResources.channels;
% %             p.clickedSpotsCollection = clickedSpotsCollection(objectHandle);
% %             p.currPoints = p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
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
%                                        
%             for i = 1:length(p.currPoints)
%                 if p.currPoints(i).Selected == 1
%                     p.currPoints(i).Selected = 0;
%                     X = p.currPoints(i).Position(1);
%                     p.clickedSpotsCollection.deleteClickedSpot(X, channels);
%                     pt = p.currPoints(i);
%                     delete(pt);
%                 end
%             end
%             p.imageWindowModule.imgAreaDisplayer.draw();
%             p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
% %             p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
% %             p.imageWindowModule.navigator.addActionBeforeMoveAttempt(p.imageWindowModule.clickedSpotsDisplayer, @deleteAllPoints);
% %             pointID = src.UserData;
%             
% %             delete(src);
%         end
%                 
        
        function deleteLastButtonPushed(p, src, eventdata)
            objectHandle = p.buildResources.objectHandle;
            channels = p.buildResources.channels;
%             p.clickedSpotsCollection = clickedSpotsCollection(objectHandle);
%             p.currPoints = p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
            n_channels = length(channels);

            if n_channels == 1
                p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_one(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
            elseif n_channels == 2
                p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_two(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
            elseif n_channels == 3
                p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_three(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
            elseif n_channels == 4
                p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_four(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
            elseif n_channels == 5
                p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_five(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
            end

            p.clickedSpotsCollection.deleteLastClickedSpot();
%             pt = p.currPoints(length(p.currPoints));
%             p.currPoints(end) = [];
%             delete(p.currPoints);
            p.imageWindowModule.imgAreaDisplayer.draw();
                p.imageWindowModule.clickedSpotsDisplayer.deleteAllPoints();
                p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
%             p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
%             p.imageWindowModule.navigator.addActionBeforeMoveAttempt(p.imageWindowModule.clickedSpotsDisplayer, @deleteAllPoints);
%             pointID = src.UserData;
            
%             delete(src);
        end
        
%         function p = deselectButtonPushed(p,src,eventdata)
%             for i = 1:length(p.newPoints)
%                 p.newPoints(i).Selected = 0;
%             end
%         end
        
        %         function getSelectedPoints(p, src, eventData)
%             p.selectedPoints = images.roi.Point;
%             
%             
%         end

        
        function pointMoved(p,src,eventData)
            %src
            fprintf('Moving spot %s', sprintf([num2str(src.UserData), '\n']));
            %fprintf('Moving\n');
            objectHandle = p.buildResources.objectHandle;
            channels = p.buildResources.channels;

                n_channels = length(channels);

                if n_channels == 1
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_one(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                elseif n_channels == 2
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_two(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                elseif n_channels == 3
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_three(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                elseif n_channels == 4
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_four(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                elseif n_channels == 5
                    p.clickedSpotsCollection = improc2.txnSites3.clickedSpotsCollection_five(objectHandle, 'nodeName', p.buildResources.nodeName, 'channels', channels);
                end
                
            p.clickedSpotsCollection.moveClickedSpot(src.UserData, eventData.CurrentPosition(1), eventData.CurrentPosition(2));
%             p.pointTableHandle.allPoints(p.pointTableHandle.allPoints.pointID == src.UserData,:)
%             p.drawLines();
            p.imageWindowModule.clickedSpotsDisplayer.deleteAllPoints();
            p.imageWindowModule.imgAreaDisplayer.draw();
            
            p.currPoints = p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
            
%             p.imageWindowModule.imgAreaDisplayer.drawPoints();
        end
        
        function deselectAllButtonPushed(p,src,eventdata)
            fprintf('deselecting points\n');
            
%             p.imageWindowModule = ImageWindowModule(forImageWindow);
%             p.imageWindowModule.navigator.addActionBeforeMoveAttempt(p.imageWindowModule.clickedSpotsDisplayer, @deleteAllPoints);
%             p.currPoints = p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
%             p.currPoints = p.imageWindowModule.currPoints;
%             p.clickedSpotsCollection = clickedSpotsCollection(objectHandle);
              p.imageWindowModule.clickedSpotsDisplayer.deleteAllPoints();
              p.imageWindowModule.clickedSpotsDisplayer.drawPoints();

%             for i = 1:length(p.currPoints)
%                 p.currPoints(i).Selected = 0;
%             end
             
%             p.imageWindowModule.clickedSpotsDisplayer.deleteAllPoints();
%             p.imageWindowModule.clickedSpotsDisplayer.drawPoints();
        end
        
    end
end

