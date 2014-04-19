function [imageWindowModule, imageContrastModule] = buildImageWindowModule(resources)
    
    rnaProcessorDataHolder = resources.rnaProcessorDataHolder;
    saturationValuesHolder = resources.saturationValuesHolder;
    gui = resources.gui;
    rnaScaledImageHolder = resources.rnaScaledImageHolder;
    objectHandle = resources.objectHandle;
    viewportHolder = resources.viewportHolder;
    
    forContraster = struct();
    forContraster.rnaProcessorDataHolder = rnaProcessorDataHolder;
    forContraster.saturationValuesHolder = saturationValuesHolder;
    forContraster.gui = gui;
    imageContrastModule = improc2.thresholdGUI.RNAImageContrastModule(...
        forContraster);
    
    forImWindowModule = struct();
    forImWindowModule.rnaScaledImageHolder = rnaScaledImageHolder;
    forImWindowModule.objectHandle = objectHandle;
    forImWindowModule.rnaProcessorDataHolder = rnaProcessorDataHolder;
    forImWindowModule.viewportHolder = viewportHolder;
    forImWindowModule.gui = gui;
    forImWindowModule.imageContrastModule = imageContrastModule;
    
    imageWindowModule = improc2.thresholdGUI.ImageWindowModule(forImWindowModule);
end

