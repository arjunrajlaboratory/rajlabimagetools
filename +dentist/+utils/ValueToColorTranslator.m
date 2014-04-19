classdef ValueToColorTranslator < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        scalingFunction
        colormap
    end
    
    methods
        function p = ValueToColorTranslator(scalingFunction, colormap)
            p.setScalingFunction(scalingFunction);
            p.setColorMap(colormap);
        end
        
        function rgb = translateToRGB(p, values)
            scaledValues = p.scalingFunction(values);
            colormapLength = size(p.colormap, 1);
            colormapIndexForValues =  1 + round((colormapLength - 1) * scaledValues);
            rgb = p.colormap(colormapIndexForValues, :);
        end
        
        function setColorMap(p, colormap)
            iptcheckmap(colormap, 'setColorMap', 'colormap', 1)
            p.colormap = colormap;
        end
        
        function setScalingFunction(p, scalingFunction)
            assert(isa(scalingFunction, 'function_handle'), ...
                'Input must be a function handle');
            p.scalingFunction = scalingFunction;
        end
    end
    
end

