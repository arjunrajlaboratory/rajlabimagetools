classdef PolygonsDisplayer < dentist.utils.AbstractDisplayer
    %UNTITLED20 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private, SetAccess = private)
        axH;
        polygonStack
        polygonHandles;
    end
    
    methods
        function p = PolygonsDisplayer(axH, polygonStack)
            p.axH = axH;
            p.polygonStack = polygonStack;
        end
        
        function draw(p)
            p.clearGraphics();
            polygonCellArray = p.polygonStack.getPolygons();
            isFirstPolygon = true;
            
            for i = 1:length(polygonCellArray)
                polygon = polygonCellArray{i};
                h = patch(polygon(:,1), polygon(:,2), 'g', ...
                    'Parent', p.axH, 'HitTest', 'off');
                if isFirstPolygon
                    p.polygonHandles = h;
                    isFirstPolygon = false;
                else
                    p.polygonHandles = [p.polygonHandles, h];
                end
            end
        end
        
        function deactivate(p)
            p.clearGraphics();
        end
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ~isempty(p.polygonHandles) && ishandle(p.polygonHandles(1))
                delete(p.polygonHandles);
                p.polygonHandles = [];
            end
        end
    end
    
    
end

