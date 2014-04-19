classdef ObjectMaskDisplayerFromObjHolder < handle
    
    properties (Access = private)
        objHolder
        figH
        axH
    end
    
    methods
        function p = ObjectMaskDisplayerFromObjHolder(objHolder)
           p.objHolder = objHolder;
           p.buildGUI();
        end
        
        function draw(p)
           imshow(p.objHolder.obj.object_mask.mask, 'Parent', p.axH, ...
               'InitialMagnification', 'fit');
        end
    end
    
    methods (Access = private)
        function buildGUI(p)
            p.figH = figure();
            p.axH = axes('Parent', p.figH);
        end
    end
    
end

