classdef GroupedCentroidsDisplayer < dentist.utils.AbstractDisplayer
    
    properties (Access = private)
        axH
        displayedTextH
        centroidsSource
        centroidsGrouping
    end
    
    
    methods
        function p = GroupedCentroidsDisplayer(axH, centroidsSource, centroidsGrouping)
            p.axH = axH;
            p.centroidsSource = centroidsSource;
            p.centroidsGrouping = centroidsGrouping;
        end
        
        
        function draw(p)
            p.clearGraphics();
            centroids = p.centroidsSource.getCentroids();
            
            assignedGroups = [];
            for i = 1:length(p.centroidsGrouping)
                assignedGroups = [assignedGroups, p.centroidsGrouping.getGroupAssignedTo(i)];
            end
            
            Xs = centroids.xPositions;
            Ys = centroids.yPositions;
            
            p.displayedTextH = text(Xs, Ys, num2cell(assignedGroups), ...
                'Color', [0 0 0], ...
                'Parent', p.axH, 'HitTest', 'off');
        end
        
        function deactivate(p)
            p.clearGraphics();
        end
        
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ~isempty(p.displayedTextH) && ishandle(p.displayedTextH(1))
                delete(p.displayedTextH);
            end
        end
    end
    
end

