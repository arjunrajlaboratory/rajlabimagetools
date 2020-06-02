classdef RNAImageContrastModule < handle
    
    properties (Access = private)
        contraster
        saturationValuesHolder
        actionsAfterSettingsChange
        
        rnaProcessorDataHolder
        gui
    end
    
    methods
        function p = RNAImageContrastModule(resources)
            p.rnaProcessorDataHolder = resources.rnaProcessorDataHolder;
            p.saturationValuesHolder = resources.saturationValuesHolder;
            p.gui = resources.gui;
            p.actionsAfterSettingsChange = improc2.utils.DependencyRunner();
            
            p.build()
        end
        
        function addActionAfterSettingsChange(p, handleToObject, funcToRunOnIt)
            p.actionsAfterSettingsChange.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        function img = contrast(p, varargin)
            img = p.contraster.contrast(varargin{:});
        end
        
        function setMode(p, contrastModeName)
            p.contraster.setMode(contrastModeName)
            p.actionsAfterSettingsChange.runDependencies();
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
            fprintf('* Modes:\n')
            fprintf('\t''%s''\n', p.contraster.contrasterNames{:})
        end
    end
    
    methods (Access = private)
        
        function build(p)
            gui = p.gui;
            
            identityContraster = improc2.utils.IdentityContraster();
            
            funcHandleToCurrentThreshold = @() p.rnaProcessorDataHolder.processorData.threshold;
            thresholdContraster = improc2.utils.MaxSettingContraster(...
                funcHandleToCurrentThreshold);
            
            
            funcHandleToFixedSaturationValue = @() p.saturationValuesHolder.getSaturationValue();
            fixedContraster = improc2.utils.MaxSettingContraster(...
                funcHandleToFixedSaturationValue);
            
            contrastersStruct = struct('threshold', thresholdContraster, ...
                'fit', identityContraster, ...
                'fixed', fixedContraster);
            
            modeSwitchableContraster =  improc2.utils.MultiModeContraster(contrastersStruct);
            
            p.contraster = modeSwitchableContraster;
            
            contrastButtons = struct('threshold', gui.thresholdContrastRadio,...
                'fit', gui.fitContrastRadio, ...
                'fixed', gui.fixedContrastRadio);
            
            actionOnToggleToContrastButton = struct(...
                'threshold', @() p.setMode('threshold'), ...
                'fit', @() p.setMode('fit'),...
                'fixed', @() p.setMode('fixed'));
            
            actionOnContrastButtonToggleOut = struct('threshold', @improc2.utils.doNothing, ...
                'fit', @improc2.utils.doNothing, 'fixed', @improc2.utils.doNothing);
            
            contrastToggleGroup = dentist.utils.FunctionExecutingToggleGroup(contrastButtons, ...
                actionOnToggleToContrastButton, actionOnContrastButtonToggleOut);
            
            contrastToggleGroup.initialize('fit');
        end
    end
    
end

