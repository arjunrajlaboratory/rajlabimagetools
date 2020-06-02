classdef ImageWindowModule < handle
    
    properties (SetAccess = private)
        viewportHolder
    end
    
    properties
        currPoints
        paramsForComposite
        imgAreaDisplayer
        clickedSpotsDisplayer
        visibilityToggleableSegmentationDisplayer;
        visibilityToggleableSpotsDisplayer;
        navigator
    end
    
    methods
        function p = ImageWindowModule(resources)
            p.build(resources)
        end
        
        function draw(p)
            p.imgAreaDisplayer.draw()
        end
        
        function setShowDapiInComposite(p, trueOrFalse)
            p.paramsForComposite.setValue('showDapi', trueOrFalse)
        end
        
        function toggleDapi(p)
            currentValue = p.paramsForComposite.getValue('showDapi');
            p.setShowDapiInComposite(~ currentValue);
        end
        
        function setShowTransInComposite(p, trueOrFalse)
            p.paramsForComposite.setValue('showTrans', trueOrFalse)
        end
        
        function toggleTrans(p)
            currentValue = p.paramsForComposite.getValue('showTrans');
            p.setShowTransInComposite(~ currentValue);
        end
        
        function setShowAlexaInComposite(p, trueOrFalse)
            p.paramsForComposite.setValue('showAlexa', trueOrFalse)
        end
        
        function toggleAlexa(p)
            currentValue = p.paramsForComposite.getValue('showAlexa');
            p.setShowAlexaInComposite(~ currentValue);
        end
        
        function setShowTmrInComposite(p, trueOrFalse)
            p.paramsForComposite.setValue('showTmr', trueOrFalse)
        end
        
        function toggleTmr(p)
            currentValue = p.paramsForComposite.getValue('showTmr');
            p.setShowTmrInComposite(~ currentValue);
        end
        
        function setShowCyInComposite(p, trueOrFalse)
            p.paramsForComposite.setValue('showCy', trueOrFalse)
        end
        
        function toggleCy(p)
            currentValue = p.paramsForComposite.getValue('showCy');
            p.setShowCyInComposite(~ currentValue);
        end
        
        function setShowGfpInComposite(p, trueOrFalse)
            p.paramsForComposite.setValue('showGfp', trueOrFalse)
        end
        
        function toggleGfp(p)
            currentValue = p.paramsForComposite.getValue('showGfp');
            p.setShowGfpInComposite(~ currentValue);
        end
        
        function setShowNirInComposite(p, trueOrFalse)
            p.paramsForComposite.setValue('showNir', trueOrFalse)
        end
        
        function toggleNir(p)
            currentValue = p.paramsForComposite.getValue('showNir');
            p.setShowNirInComposite(~ currentValue);
        end
        
        
        
        
        
        function setScaleGfpInComposite(p, numeric)
            p.paramsForComposite.setValue('scaleGfp', numeric)
        end
        
        function scaleGfp(p)
            currentValue = p.paramsForComposite.getValue('scaleGfp');
            p.setScaleGfpInComposite(~ currentValue);
        end
        
        function setScaleNirInComposite(p, numeric)
            p.paramsForComposite.setValue('scaleNir', numeric)
        end
        
        function scaleNir(p)
            currentValue = p.paramsForComposite.getValue('scaleNir');
            p.setScaleNirInComposite(~ currentValue);
        end
        
        function setScaleAlexaInComposite(p, numeric)
            p.paramsForComposite.setValue('scaleAlexa', numeric)
        end
        
        function scaleAlexa(p)
            currentValue = p.paramsForComposite.getValue('scaleAlexa');
            p.setScaleAlexaInComposite(~ currentValue);
        end
        
        function setScaleCyInComposite(p, numeric)
            p.paramsForComposite.setValue('scaleCy', numeric)
        end
        
        function scaleCy(p)
            currentValue = p.paramsForComposite.getValue('scaleCy');
            p.setScaleCyInComposite(~ currentValue);
        end
        
        function setScaleTmrInComposite(p, numeric)
            p.paramsForComposite.setValue('scaleTmr', numeric)
        end
        
        function scaleTmr(p)
            currentValue = p.paramsForComposite.getValue('scaleTmr');
            p.setScaleTmrInComposite(~ currentValue);
        end
        
        function setScaleDapiInComposite(p, numeric)
            p.paramsForComposite.setValue('scaleDapi', numeric)
        end
        
        function scaleDapi(p)
            currentValue = p.paramsForComposite.getValue('scaleDapi');
            p.setScaleDapiInComposite(~ currentValue);
        end
        
        function setScaleTransInComposite(p, numeric)
            p.paramsForComposite.setValue('scaleTrans', numeric)
        end
        
        function scaleTrans(p)
            currentValue = p.paramsForComposite.getValue('scaleTrans');
            p.setScaleTransInComposite(~ currentValue);
        end
        
        
        
        
        
        
        
        function setCircleGfpInComposite(p, numeric)
            p.paramsForComposite.setValue('circleGfp', numeric)
        end
        
        function circleGfp(p)
            currentValue = p.paramsForComposite.getValue('circleGfp');
            p.setCircleGfpInComposite(~ currentValue);
        end
        
        function setCircleNirInComposite(p, numeric)
            p.paramsForComposite.setValue('circleNir', numeric)
        end
        
        function circleNir(p)
            currentValue = p.paramsForComposite.getValue('circleNir');
            p.setCircleNirInComposite(~ currentValue);
        end
        
        function setCircleAlexaInComposite(p, numeric)
            p.paramsForComposite.setValue('circleAlexa', numeric)
        end
        
        function circleAlexa(p)
            currentValue = p.paramsForComposite.getValue('circleAlexa');
            p.setCircleAlexaInComposite(~ currentValue);
        end
        
        function setCircleCyInComposite(p, numeric)
            p.paramsForComposite.setValue('circleCy', numeric)
        end
        
        function circleCy(p)
            currentValue = p.paramsForComposite.getValue('circleCy');
            p.setCircleCyInComposite(~ currentValue);
        end
        
        function setCircleTmrInComposite(p, numeric)
            p.paramsForComposite.setValue('circleTmr', numeric)
        end
        
        function circleTmr(p)
            currentValue = p.paramsForComposite.getValue('circleTmr');
            p.setCircleTmrInComposite(~ currentValue);
        end
        
        
        
        function setColorTmrInComposite(p, numeric)
            p.paramsForComposite.setValue('colorTmr', numeric)
        end
        
        function colorTmr(p)
            currentValue = p.paramsForComposite.getValue('colorTmr');
            p.setColorTmrInComposite(~ currentValue);
        end
        
        function setColorAlexaInComposite(p, numeric)
            p.paramsForComposite.setValue('colorAlexa', numeric)
        end
        
        function colorAlexa(p)
            currentValue = p.paramsForComposite.getValue('colorAlexa');
            p.setColorAlexaInComposite(~ currentValue);
        end        
        
        function setColorCyInComposite(p, numeric)
            p.paramsForComposite.setValue('colorCy', numeric)
        end
        
        function colorCy(p)
            currentValue = p.paramsForComposite.getValue('colorCy');
            p.setColorCyInComposite(~ currentValue);
        end        
        
        function setColorGfpInComposite(p, numeric)
            p.paramsForComposite.setValue('colorGfp', numeric)
        end
        
        function colorGfp(p)
            currentValue = p.paramsForComposite.getValue('colorGfp');
            p.setColorGfpInComposite(~ currentValue);
        end        

        function setColorNirInComposite(p, numeric)
            p.paramsForComposite.setValue('colorNir', numeric)
        end
        
        function colorNir(p)
            currentValue = p.paramsForComposite.getValue('colorNir');
            p.setColorNirInComposite(~ currentValue);
        end        
        
        
        
        function setColorDapiInComposite(p, numeric)
            p.paramsForComposite.setValue('colorDapi', numeric)
        end
        
        function colorDapi(p)
            currentValue = p.paramsForComposite.getValue('colorDapi');
            p.setColorDapiInComposite(~ currentValue);
        end        
        
        function setColorTransInComposite(p, numeric)
            p.paramsForComposite.setValue('colorTrans', numeric)
        end
        
        function colorTrans(p)
            currentValue = p.paramsForComposite.getValue('colorTrans');
            p.setColorTransInComposite(~ currentValue);
        end        
%         function setSegmentationVisibility(p, trueOrFalse)
%             p.visibilityToggleableSegmentationDisplayer...
%                 .setVisibilityAndDrawIfActive(trueOrFalse)
%         end
%         
%         function setSpotsVisibility(p, trueOrFalse)
%             p.visibilityToggleableSpotsDisplayer...
%                 .setVisibilityAndDrawIfActive(trueOrFalse)
%         end
%         
%         function toggleSpots(p)
%            currentVisibility =  p.visibilityToggleableSpotsDisplayer.visible;
%            p.setSpotsVisibility(~ currentVisibility);
%         end
%         
%         function toggleSegmentation(p)
%             currentVisibility =  p.visibilityToggleableSegmentationDisplayer.visible;
%             p.setSegmentationVisibility(~ currentVisibility);
%         end
        

    end
    
    methods (Access = private)
        function build(p, resources)
            
            rnaScaledImageHolder = resources.rnaScaledImageHolder;
            rnaProcessorDataHolder = resources.rnaProcessorDataHolder;
            imageContrastModule = resources.imageContrastModule;
            viewportHolder = resources.viewportHolder;
            objectHandle = resources.objectHandle;
            gui = resources.gui;
            navgui = resources.navgui;
            paramsForComposite = resources.paramsForComposite;
            navigator = resources.navigator;
            channels = resources.channels;
            nodeName = resources.nodeName;
            
%                 channels = improc2.thresholdGUI.findRNAChannels(objectHandle);
                
            paramsForComposite = improc2.utils.buildTypeCheckedValuesFromStruct(...
            struct('showDapi', true, 'showTrans', false, 'showAlexa', false, 'showTmr', false, 'showCy', false, 'showNir', false, 'showGfp', false,...
            'scaleDapi', 1, 'scaleTrans', 1, 'scaleAlexa', 1, 'scaleTmr', 1, 'scaleCy', 1, 'scaleNir', 1, 'scaleGfp', 1,...
            'circleAlexa', 0, 'circleTmr', 0, 'circleCy', 0, 'circleNir', 0, 'circleGfp', 0,...
            'colorDapi', {[1, 0, 1]}, 'colorTrans', {[1, 1, 0]}, 'colorAlexa', {[1, 0, 0]}, 'colorTmr', {[0, 1, 0]}, 'colorCy', {[1, 1, 1]}, 'colorNir', {[1, 0, 0]}, 'colorGfp', {[0, 1, 0]}));

            UIToParamsForComposite = improc2.utils.UISynchronizedNamedValuesAndChoices(...
                paramsForComposite);
            navgui = resources.navgui;
%             channels = improc2.thresholdGUI.findRNAChannels(objectHandle);
            if max(ismember(channels, 'gfp'))
            UIToParamsForComposite.attachUIControl('showGfp', navgui.gfp_display)
            end
            if max(ismember(channels, 'nir'))
            UIToParamsForComposite.attachUIControl('showNir', navgui.nir_display)
            end
            if max(ismember(channels, 'tmr'))
            UIToParamsForComposite.attachUIControl('showTmr', navgui.tmr_display)
            end
            if max(ismember(channels, 'cy'))
            UIToParamsForComposite.attachUIControl('showCy', navgui.cy_display)
            end
            if max(ismember(channels, 'alexa'))
            UIToParamsForComposite.attachUIControl('showAlexa', navgui.alexa_display)
            end
            
            if max(ismember(channels, 'gfp'))
            UIToParamsForComposite.attachUIControl('scaleGfp', navgui.gfp_scale)
            end
            if max(ismember(channels, 'nir'))
            UIToParamsForComposite.attachUIControl('scaleNir', navgui.nir_scale)
            end
            if max(ismember(channels, 'tmr'))
            UIToParamsForComposite.attachUIControl('scaleTmr', navgui.tmr_scale)
            end
            if max(ismember(channels, 'cy'))
            UIToParamsForComposite.attachUIControl('scaleCy', navgui.cy_scale)
            end
            if max(ismember(channels, 'alexa'))
            UIToParamsForComposite.attachUIControl('scaleAlexa', navgui.alexa_scale)
            end
            

            
            
            
            if max(ismember(channels, 'gfp'))
            UIToParamsForComposite.attachUIControl('circleGfp', navgui.gfp_circlenumber)
            end
            if max(ismember(channels, 'nir'))
            UIToParamsForComposite.attachUIControl('circleNir', navgui.nir_circlenumber)
            end
            if max(ismember(channels, 'tmr'))
            UIToParamsForComposite.attachUIControl('circleTmr', navgui.tmr_circlenumber)
            end
            if max(ismember(channels, 'cy'))
            UIToParamsForComposite.attachUIControl('circleCy', navgui.cy_circlenumber)
            end
            if max(ismember(channels, 'alexa'))
            UIToParamsForComposite.attachUIControl('circleAlexa', navgui.alexa_circlenumber)
            end
            
            
            
            
            
            
            
            if max(ismember(channels, 'gfp'))
            UIToParamsForComposite.attachUIControl('colorGfp', navgui.gfp_color)
            end
            if max(ismember(channels, 'nir'))
            UIToParamsForComposite.attachUIControl('colorNir', navgui.nir_color)
            end
            if max(ismember(channels, 'tmr'))
            UIToParamsForComposite.attachUIControl('colorTmr', navgui.tmr_color)
            end
            if max(ismember(channels, 'cy'))
            UIToParamsForComposite.attachUIControl('colorCy', navgui.cy_color)
            end
            if max(ismember(channels, 'alexa'))
            UIToParamsForComposite.attachUIControl('colorAlexa', navgui.alexa_color)
            end
            
            UIToParamsForComposite.attachUIControl('colorDapi', navgui.dapi_color)
            UIToParamsForComposite.attachUIControl('colorTrans', navgui.trans_color)
            
            
            
            
            %     channels = [channels 'dapi' 'trans'];
%     test = [];
%     for j = 1:length(channels)
%         name = [(channels{j}) '_color'];
%     set(gui.(name), 'CallBack', @(varargin) uisetcolor)
%     test = [test, get(gui.(name), 'Value')];
%     test
%     end
            
            
%             if max(ismember(channels, 'gfp'))
%             UIToParamsForComposite.attachUIControl('circleGfp', navgui.gfp_circlenumber)
%             end
%             if max(ismember(channels, 'nir'))
%             UIToParamsForComposite.attachUIControl('circleNir', navgui.nir_circlenumber)
%             end
%             if max(ismember(channels, 'tmr'))
%             UIToParamsForComposite.attachUIControl('circleTmr', navgui.tmr_circlenumber)
%             end
%             if max(ismember(channels, 'cy'))
%             UIToParamsForComposite.attachUIControl('circleCy', navgui.cy_circlenumber)
%             end
%             if max(ismember(channels, 'alexa'))
%             UIToParamsForComposite.attachUIControl('circleAlexa', navgui.alexa_circlenumber)
%             end
%             UIToParamsForComposite.attachUIControl('scaleDapi', navgui.dapi_scale)
%             UIToParamsForComposite.attachUIControl('scaleTrans', navgui.trans_scale) 
%             
            
            
            UIToParamsForComposite.attachUIControl('scaleDapi', navgui.dapi_scale)
            UIToParamsForComposite.attachUIControl('scaleTrans', navgui.trans_scale)
            UIToParamsForComposite.attachUIControl('showDapi', navgui.dapi_display)
            UIToParamsForComposite.attachUIControl('showTrans', navgui.trans_display)
            
%             
%             rnaContrastedImageHolder = improc2.utils.ContrastedScaledImageHolder(...
%                 rnaScaledImageHolder, ...
%                 imageContrastModule);
            
            transImageHolder = ...
                improc2.utils.ImageHolderFromImageObjectHandle(objectHandle, 'trans');
            
            dapiImageHolder = ...
                improc2.utils.ImageHolderFromImageObjectHandle(objectHandle, 'dapi');
            nirImageHolder = ...
                improc2.utils.ImageHolderFromImageObjectHandle(objectHandle, 'nir:Spots');
            alexaImageHolder = ...
                improc2.utils.ImageHolderFromImageObjectHandle(objectHandle, 'alexa:Spots');
            cyImageHolder = ...
                improc2.utils.ImageHolderFromImageObjectHandle(objectHandle, 'cy:Spots');
            tmrImageHolder = ...
                improc2.utils.ImageHolderFromImageObjectHandle(objectHandle, 'tmr:Spots');
            gfpImageHolder = ...
                improc2.utils.ImageHolderFromImageObjectHandle(objectHandle, 'gfp:Spots');
%             channels = improc2.thresholdGUI.findRNAChannels(objectHandle);

%             if max(ismember(channels, 'nir'))
%             nirSpotsHolder = ...
%                 objectHandle.getData('nir:Fitted').getFittedSpots();
%             else
%                 nirSpotsHolder = [];
%             end
%             if max(ismember(channels, 'alexa'))
%             alexaSpotsHolder = ...
%                 objectHandle.getData('alexa:Fitted').getFittedSpots();
%             else
%                 alexaSpotsHolder = [];
%             end
%             if max(ismember(channels, 'cy'))
%             cySpotsHolder = ...
%                 objectHandle.getData('cy:Fitted').getFittedSpots();
%             else
%                 cySpotsHolder = [];
%             end
%             if max(ismember(channels, 'tmr'))
%             tmrSpotsHolder = ...
%                 objectHandle.getData('tmr:Fitted').getFittedSpots();
%             else
%                 tmrSpotsHolder = [];
%             end
%             if max(ismember(channels, 'gfp'))
%             gfpSpotsHolder = ...
%                 objectHandle.getData('gfp:Fitted').getFittedSpots();
%             else
%                 gfpSpotsHolder = [];
%             end


            compositeImageMaker = improc2.txnSites3.CompositeImageMaker(...
                alexaImageHolder, cyImageHolder, tmrImageHolder, nirImageHolder, gfpImageHolder, dapiImageHolder, transImageHolder, paramsForComposite);
            
            compositeImageDisplayer = improc2.utils.ImageDisplayer(...
                gui.imgAx, compositeImageMaker, viewportHolder);
            
%             spotsDisplayer = topNSpotsDisplayer(gui.imgAx, nirSpotsHolder, alexaSpotsHolder, cySpotsHolder, tmrSpotsHolder, gfpSpotsHolder, paramsForComposite);
            spotsDisplayer = improc2.txnSites3.topNSpotsDisplayer(gui.imgAx, objectHandle, paramsForComposite, channels);
%             spotsDisplayer = 
            
            
%             spotsDisplayer = topNSpotsDisplayer(gui.imgAx, spotsProvider);
%             visibilityToggleableSpotsDisplayer = ...
%                 dentist.utils.VisibilityToggleableDisplayer(spotsDisplayer);
%             visibilityToggleableSpotsDisplayer.attachVisibilityUIControl(gui.spotsCheck);
            
            
            segmentationMaskProvider = improc2.utils.MaskProviderFromCroppedMaskProvider(objectHandle);
            segmentationDisplayer = improc2.utils.MaskDisplayer(gui.imgAx, segmentationMaskProvider);
            visibilityToggleableSegmentationDisplayer = ...
                dentist.utils.VisibilityToggleableDisplayer(segmentationDisplayer);
%             visibilityToggleableSegmentationDisplayer.attachVisibilityUIControl(gui.segmentCheck);

                n_channels = length(channels);

                if n_channels == 1
                    clickedSpotsCollectionVar = improc2.txnSites3.notifyingClickedSpotsCollection(...
                    improc2.txnSites3.clickedSpotsCollection_one(objectHandle, 'nodeName', nodeName, 'channels', channels));
                elseif n_channels == 2
                    clickedSpotsCollectionVar = improc2.txnSites3.notifyingClickedSpotsCollection(...
                    improc2.txnSites3.clickedSpotsCollection_two(objectHandle, 'nodeName', nodeName, 'channels', channels));
                elseif n_channels == 3
                    clickedSpotsCollectionVar = improc2.txnSites3.notifyingClickedSpotsCollection(...
                    improc2.txnSites3.clickedSpotsCollection_three(objectHandle, 'nodeName', nodeName, 'channels', channels));
                elseif n_channels == 4
                    clickedSpotsCollectionVar = improc2.txnSites3.notifyingClickedSpotsCollection(...
                    improc2.txnSites3.clickedSpotsCollection_four(objectHandle, 'nodeName', nodeName, 'channels', channels));
                elseif n_channels == 5
                    clickedSpotsCollectionVar = improc2.txnSites3.notifyingClickedSpotsCollection(...
                    improc2.txnSites3.clickedSpotsCollection_five(objectHandle, 'nodeName', nodeName, 'channels', channels));
                end

%             clickedSpotsCollectionVar = notifyingClickedSpotsCollection(...
%                 clickedSpotsCollection(objectHandle));

            clickedSpotsDisplayerforImageWindow = improc2.txnSites3.clickedSpotsDisplayer(gui.imgAx, clickedSpotsCollectionVar, paramsForComposite);
            
            imgAreaDisplayer = dentist.utils.DisplayerSequence(...
                compositeImageDisplayer, ...
                visibilityToggleableSegmentationDisplayer,...
                spotsDisplayer,...
                clickedSpotsDisplayerforImageWindow);
%                 visibilityToggleableSpotsDisplayer...
            

            navigator.addActionBeforeMoveAttempt(clickedSpotsDisplayerforImageWindow, @deleteAllPoints);
            navigator.addActionAfterMoveAttempt(clickedSpotsDisplayerforImageWindow, @drawPoints);
            navigator.addActionAfterMoveAttempt(spotsDisplayer, @draw);

                
            
            imgAreaDisplayer.draw();
            clickedSpotsDisplayerforImageWindow.drawPoints();
            
%              UIToParamsForComposite = improc2.utils.UISynchronizedNamedValuesAndChoices(...
%                 paramsForComposite);
            UIToParamsForComposite.addActionAfterSettingAnyValue(imgAreaDisplayer, @draw)
            imageContrastModule.addActionAfterSettingsChange(imgAreaDisplayer, @draw)
%             UIToParamsForComposite.addActionAfterSettingAnyValue(clickedSpotsDisplayerforImageWindow, @deleteAllPoints)
%             imageContrastModule.addActionAfterSettingsChange(clickedSpotsDisplayerforImageWindow, @deleteAllPoints)
%             test = get(gui.imgAx, 'Children');
            
%             zoomInterpreter = dentist.utils.ImageZoomingMouseInterpreter(viewportHolder);
%             zoomInterpreter.wireToFigureAndAxes(gui.figH, gui.imgAx);
            p.clickedSpotsDisplayer = clickedSpotsDisplayerforImageWindow; 
            p.paramsForComposite = UIToParamsForComposite;
            p.imgAreaDisplayer = imgAreaDisplayer;
            p.visibilityToggleableSegmentationDisplayer = ...
                visibilityToggleableSegmentationDisplayer;
%             p.visibilityToggleableSpotsDisplayer = ...
%                 visibilityToggleableSpotsDisplayer;
            p.viewportHolder = viewportHolder;
            p.navigator = navigator;
            p.currPoints = clickedSpotsDisplayerforImageWindow.currPoints;
        end
    end
    
end

