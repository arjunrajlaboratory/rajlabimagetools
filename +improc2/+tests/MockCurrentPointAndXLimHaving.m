classdef MockCurrentPointAndXLimHaving < hgsetget
    
    properties
        CurrentPoint
        XLim
    end
    
    methods
        function val = get.CurrentPoint(p)
            val = p.CurrentPoint;
        end
        function set.CurrentPoint(p, val)
            p.CurrentPoint = val;
        end
        function set.XLim(p, limits)
            p.XLim = limits;
        end
        function lims = get.XLim(p)
            lims = p.XLim;
        end
    end
end

