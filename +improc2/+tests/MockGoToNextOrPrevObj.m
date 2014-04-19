classdef MockGoToNextOrPrevObj < handle
    
    properties (SetAccess = private)
        timesGoToNext = 0;
        timesGoToPrev = 0;
    end
    
    methods
        function tryToGoToNextObj(p)
            p.timesGoToNext = p.timesGoToNext + 1;
        end
        function tryToGoToPrevObj(p)
            p.timesGoToPrev = p.timesGoToPrev + 1;
        end
    end
    
end

