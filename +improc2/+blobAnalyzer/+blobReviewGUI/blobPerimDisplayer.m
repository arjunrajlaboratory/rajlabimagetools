classdef blobPerimDisplayer <  handle
    
    properties (Access = private)
        axH
        blobPerimProvider
        lineHandle
    end
    
    methods
        function p = blobPerimDisplayer(axH, blobPerimProvider)
            p.axH = axH;
            p.blobPerimProvider = blobPerimProvider;
        end
        function draw(p)
            p.clearGraphics()
            [Xs, Ys] = getMaskPerimeterCoordinates(p);
            p.lineHandle = line(Xs, Ys, ...
                'LineStyle', 'none', ...
                'Marker', '.', 'MarkerEdgeColor', 'g', ...
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
%             blobMasks = p.processorDataHolder.processorData.getBlobMasks();
%             sB = bwperim(mask);
            [blobMasks, perimeters] = p.blobPerimProvider.getPerimeters();
            [I,J] = ind2sub(size(blobMasks),find(perimeters(:)));
            Xs = J;
            Ys = I;

        end
    end
    
end

