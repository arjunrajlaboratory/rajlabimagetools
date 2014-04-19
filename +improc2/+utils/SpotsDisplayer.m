classdef SpotsDisplayer <  handle
    
    properties (Access = private)
        axH
        spotsProvider
        lineHandle
    end
    
    methods
        function p = SpotsDisplayer(axH, spotsProvider)
            p.axH = axH;
            p.spotsProvider = spotsProvider;
        end
        function draw(p)
            p.clearGraphics()
            [Xs, Ys] = p.get2dSpotPositions();
            p.lineHandle = line(Xs, Ys, ...
                    'LineStyle', 'none', ...
                    'Marker','o', 'MarkerEdgeColor', 'g', ...
                    'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 14);
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
        function [Xs, Ys] = get2dSpotPositions(p)
            [I, J] = p.spotsProvider.getSpotCoordinates();
            Xs = J;
            Ys = I;
        end
    end
    
end

