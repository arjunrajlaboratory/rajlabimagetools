classdef MaskDisplayer < handle
    
    properties (Access = private)
        axH
        maskHolder
        lineHandle
    end
    
    methods
        function p = MaskDisplayer(axH, maskHolder)
            p.axH = axH;
            p.maskHolder = maskHolder;
        end
        function draw(p)
            p.clearGraphics()
            [Xs, Ys] = p.getMaskPerimeterCoordinates();
            p.lineHandle = line(Xs, Ys, ...
                'LineStyle', 'none', ...
                'Marker', '.', 'MarkerEdgeColor', 'r', ...
                'Parent', p.axH, 'HitTest', 'off');
        end
        function deactivate(p)
            p.clearGraphics()
        end
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ~isempty(p.lineHandle) && ishandle(p.lineHandle)
                delete(p.lineHandle)
            end
        end
        
        function [Xs, Ys] = getMaskPerimeterCoordinates(p)
            mask = p.maskHolder.getMask();
            sB = bwperim(mask);
            [I,J] = ind2sub(size(mask),find(sB(:)));
            Xs = J;
            Ys = I;
        end
    end
end

