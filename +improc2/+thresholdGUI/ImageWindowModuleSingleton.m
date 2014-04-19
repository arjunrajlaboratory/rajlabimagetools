classdef ImageWindowModuleSingleton < handle
    
    properties (Access = private)
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
            p.keyboardInterpreter = resources.keyboardInterpreter;
        end
        function launchGUI(p)
            if ~isempty(p.figH) && ishandle(p.figH)
                figure(p.figH)
            else
                p.buildGUI()
                keyboardInterpreter = p.keyboardInterpreter;
                set(p.figH, 'WindowKeyPressFcn', ...
                    @keyboardInterpreter.keyPressCallBackFunc)
            end
        end
        function toggleDapi(p)
            if isvalid(p.imageWindowModule)
                p.imageWindowModule.toggleDapi()
            end
        end
        function toggleTrans(p)
            if isvalid(p.imageWindowModule)
                p.imageWindowModule.toggleTrans()
            end
        end
        function toggleSpots(p)
            if isvalid(p.imageWindowModule)
                p.imageWindowModule.toggleSpots()
            end
        end
        function toggleSegmentation(p)
            if isvalid(p.imageWindowModule)
                p.imageWindowModule.toggleSegmentation()
            end
        end
        
        function updateIfActive(p)
            if ~isempty(p.figH) && ishandle(p.figH)
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
            gui = improc2.thresholdGUI.layOutImageInspectionGUI();
            p.figH = gui.figH;
            
            forContraster = struct();
            forContraster.rnaProcessorDataHolder    = p.buildResources.rnaProcessorDataHolder;
            forContraster.saturationValuesHolder    = p.buildResources.saturationValuesHolder;
            forContraster.gui = gui;
            imageContrastModule = improc2.thresholdGUI.RNAImageContrastModule(...
                forContraster);
            
            forImageWindow = struct();
            forImageWindow.rnaScaledImageHolder      = p.buildResources.rnaScaledImageHolder;
            forImageWindow.objectHandle              = p.buildResources.objectHandle;
            forImageWindow.rnaProcessorDataHolder    = p.buildResources.rnaProcessorDataHolder;
            forImageWindow.viewportHolder            = p.buildResources.viewportHolder;
            forImageWindow.gui                          = gui;
            forImageWindow.imageContrastModule          = imageContrastModule;
            
            set(gui.spotsCheck, 'String', '(R)NA Spots')
            set(gui.segmentCheck, 'String', 'Se(G)mentation')
            set(gui.dapiCheck, 'String', 'DA(P)I')
            set(gui.transCheck, 'String', '(T)rans')
            
            
            p.imageWindowModule = improc2.thresholdGUI.ImageWindowModule(forImageWindow);
            
            set(p.figH, 'CloseRequestFcn', @(varargin) p.figureCloseRequest())
        end
    end
end

