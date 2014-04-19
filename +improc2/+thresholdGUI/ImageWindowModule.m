classdef ImageWindowModule < handle
    
    properties (SetAccess = private)
        viewportHolder
    end
    
    properties (Access = private)
        paramsForComposite
        imgAreaDisplayer
        visibilityToggleableSegmentationDisplayer;
        visibilityToggleableSpotsDisplayer;
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
        
        function setSegmentationVisibility(p, trueOrFalse)
            p.visibilityToggleableSegmentationDisplayer...
                .setVisibilityAndDrawIfActive(trueOrFalse)
        end
        
        function setSpotsVisibility(p, trueOrFalse)
            p.visibilityToggleableSpotsDisplayer...
                .setVisibilityAndDrawIfActive(trueOrFalse)
        end
        
        function toggleSpots(p)
           currentVisibility =  p.visibilityToggleableSpotsDisplayer.visible;
           p.setSpotsVisibility(~ currentVisibility);
        end
        
        function toggleSegmentation(p)
            currentVisibility =  p.visibilityToggleableSegmentationDisplayer.visible;
            p.setSegmentationVisibility(~ currentVisibility);
        end
        

    end
    
    methods (Access = private)
        function build(p, resources)
            
            rnaScaledImageHolder = resources.rnaScaledImageHolder;
            rnaProcessorDataHolder = resources.rnaProcessorDataHolder;
            imageContrastModule = resources.imageContrastModule;
            viewportHolder = resources.viewportHolder;
            objectHandle = resources.objectHandle;
            gui = resources.gui;
            
            rnaContrastedImageHolder = improc2.utils.ContrastedScaledImageHolder(...
                rnaScaledImageHolder, ...
                imageContrastModule);
            
            transImageHolder = ...
                improc2.utils.ImageHolderFromImageObjectHandle(objectHandle, 'trans');
            
            dapiImageHolder = ...
                improc2.utils.ImageHolderFromImageObjectHandle(objectHandle, 'dapi');
            
            paramsForComposite = improc2.utils.buildTypeCheckedValuesFromStruct(...
                struct('showDapi', false, 'showTrans', false));
            
            compositeImageMaker = improc2.thresholdGUI.CompositeImageMaker(...
                rnaContrastedImageHolder, dapiImageHolder, transImageHolder, paramsForComposite);
            
            compositeImageDisplayer = improc2.utils.ImageDisplayer(...
                gui.imgAx, compositeImageMaker, viewportHolder);
            
            spotsProvider = improc2.utils.SpotsProviderFromProcessorDataHolder(rnaProcessorDataHolder);
            spotsDisplayer = improc2.utils.SpotsDisplayer(gui.imgAx, spotsProvider);
            visibilityToggleableSpotsDisplayer = ...
                dentist.utils.VisibilityToggleableDisplayer(spotsDisplayer);
            visibilityToggleableSpotsDisplayer.attachVisibilityUIControl(gui.spotsCheck);
            
            segmentationMaskProvider = improc2.utils.MaskProviderFromCroppedMaskProvider(objectHandle);
            segmentationDisplayer = improc2.utils.MaskDisplayer(gui.imgAx, segmentationMaskProvider);
            visibilityToggleableSegmentationDisplayer = ...
                dentist.utils.VisibilityToggleableDisplayer(segmentationDisplayer);
            visibilityToggleableSegmentationDisplayer.attachVisibilityUIControl(gui.segmentCheck);
            
            imgAreaDisplayer = dentist.utils.DisplayerSequence(...
                compositeImageDisplayer, ...
                visibilityToggleableSegmentationDisplayer, ...
                visibilityToggleableSpotsDisplayer);
            
            imgAreaDisplayer.draw();
            
            UIToParamsForComposite = improc2.utils.UISynchronizedNamedValuesAndChoices(...
                paramsForComposite);
            
            UIToParamsForComposite.attachUIControl('showDapi', gui.dapiCheck)
            UIToParamsForComposite.attachUIControl('showTrans', gui.transCheck)
            
            UIToParamsForComposite.addActionAfterSettingAnyValue(imgAreaDisplayer, @draw)
            imageContrastModule.addActionAfterSettingsChange(imgAreaDisplayer, @draw)
            
            zoomInterpreter = dentist.utils.ImageZoomingMouseInterpreter(viewportHolder);
            zoomInterpreter.wireToFigureAndAxes(gui.figH, gui.imgAx);
            
            p.paramsForComposite = UIToParamsForComposite;
            p.imgAreaDisplayer = imgAreaDisplayer;
            p.visibilityToggleableSegmentationDisplayer = ...
                visibilityToggleableSegmentationDisplayer;
            p.visibilityToggleableSpotsDisplayer = ...
                visibilityToggleableSpotsDisplayer;
            p.viewportHolder = viewportHolder;
        end
    end
    
end

