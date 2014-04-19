classdef MultiMouseGestureInterpreter < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private, SetAccess = private)
        figH;
        axH;
    end
    
    properties (SetAccess = private, GetAccess = private)
        structOfInterpreters;
        currentInterpreter;
    end
    
    methods
        function p = MultiMouseGestureInterpreter(figH, axH, structOfInterpreters)
            p.figH = figH;
            p.axH = axH;
            p.structOfInterpreters = structOfInterpreters;
            dragModes = fields(structOfInterpreters);
            p.setMode(dragModes{1});
        end
        

        function setMode(p, dragMode)
            p.currentInterpreter = p.structOfInterpreters.(dragMode);
            p.currentInterpreter.wireToFigureAndAxes(p.figH, p.axH)
        end
        
        function rewire(p)
            p.currentInterpreter.rewire;
        end
    end
end

