classdef ModifiedDisplayer < dentist.utils.AbstractDisplayer
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        displayer
        parametersHolder
        argumentsForParameterSetting;
    end
    
    methods
        function p = ModifiedDisplayer(displayer, parametersHolder, varargin)
            p.displayer = displayer;
            p.parametersHolder = parametersHolder;
            p.argumentsForParameterSetting = varargin;
        end
        
        function draw(p)
            p.parametersHolder.setToDefaults();
            p.parametersHolder.set(p.argumentsForParameterSetting{:});
            p.displayer.draw();
        end
        
        function deactivate(p)
            p.displayer.deactivate();
        end
    end
    
end

