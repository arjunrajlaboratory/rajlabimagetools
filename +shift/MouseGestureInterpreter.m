classdef MouseGestureInterpreter < handle
    
    properties (GetAccess = private, SetAccess = private)
        figH
    end
    
    properties (GetAccess = protected, SetAccess = private)
        axH;
        pointAtButtonDown;
        selectionTypeAtButtonDown;
        pointAtButtonUp;
    end
    
    methods
        function p = MouseGestureInterpreter()
        end
        
        function wireToFigureAndAxes(p, figHandle, axesHandle)
            p.figH = figHandle;
            p.axH = axesHandle;
            p.rewire;
        end
        
        function rewire(p)
            set([p.axH; get(p.axH, 'Children')], ...
                'ButtonDownFcn', @p.axesButtonDownCallBack);
        end
        
        function unwire(p)
            set([p.axH; get(p.axH, 'Children')], ...
                'ButtonDownFcn', '');
        end
        
        function buttonUpCallBack(p, varargin)
            set(p.figH, 'WindowButtonMotionFcn', '');
            set(p.figH, 'WindowButtonUpFcn', '');
            p.pointAtButtonUp = get(p.axH, 'CurrentPoint');
            p.doAfterButtonUp;
        end
        
        function axesButtonDownCallBack(p, varargin)
            set(p.figH, 'WindowButtonMotionFcn', @p.moveCallback);
            set(p.figH, 'WindowButtonUpFcn', @p.buttonUpCallBack);
            p.pointAtButtonDown = get(p.axH, 'CurrentPoint');
            p.selectionTypeAtButtonDown = get(p.figH, 'SelectionType');
            p.doOnButtonDown;
        end
        
        function moveCallback(p, varargin)
        end
        
        function doAfterButtonUp(p)
        end
        
        function doOnButtonDown(p)
        end
    end
    
end

