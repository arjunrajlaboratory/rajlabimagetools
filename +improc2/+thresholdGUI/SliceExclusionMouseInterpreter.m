classdef SliceExclusionMouseInterpreter < dentist.utils.RectangleDrawingInterpreter
    
    properties (SetAccess = private, GetAccess = private)
        sliceExcluder
    end
    
    methods
        function p = SliceExclusionMouseInterpreter(sliceExcluder)
            p.sliceExcluder = sliceExcluder;
        end
        
        function wireToFigureAndAxes(p, varargin)
            p.wireToFigureAndAxes@dentist.utils.RectangleDrawingInterpreter(varargin{:});
        end
        
        function doAfterButtonUp(p, varargin)
            p.doAfterButtonUp@dentist.utils.RectangleDrawingInterpreter(varargin{:});
            if p.width == 0 && p.height == 0
                p.setMaxOrMinSliceBasedOnClickType();
            elseif p.width > 0 && p.height > 0
                p.keepSlicesInRectangle();
            end
        end
    end
    
    methods (Access = private)
        function keepSlicesInRectangle(p)
            lowestSlice = round(p.y0);
            highestSlice = round(p.y0 + p.height);
            p.sliceExcluder.clearExclusionsAndIncludeOnlyBetween(lowestSlice, highestSlice)
        end
        
        function setMaxOrMinSliceBasedOnClickType(p)
            currentPoint = get(p.axH, 'CurrentPoint');
            chosenSlice = round(currentPoint(1,2));
            switch p.selectionTypeAtButtonDown
                case 'normal' %left-click
                    p.sliceExcluder.clearExclusionsAndExcludeSlicesUpTo(chosenSlice)
                case 'alt'  %right-click
                    p.sliceExcluder.clearExclusionsAndExcludeSlicesStartingFrom(chosenSlice)
            end
        end
    end
    
end

