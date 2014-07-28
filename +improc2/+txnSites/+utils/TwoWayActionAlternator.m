classdef TwoWayActionAlternator < handle
    
    properties (Access = private)
        doA = true;
        actionA
        actionB
    end
    
    methods
        function p = TwoWayActionAlternator(actionA, actionB)
            p.actionA = actionA;
            p.actionB = actionB;
        end
        
        function doOtherAction(p)
            p.doA = ~p.doA;
            if p.doA
                p.actionA();
            else
                p.actionB();
            end
        end
    end
end

