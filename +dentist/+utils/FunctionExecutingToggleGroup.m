classdef FunctionExecutingToggleGroup <  dentist.utils.MutuallyExclusiveToggleGroup
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private, SetAccess = private)
        structOfFuncsToRunOnToggleTo;
        structOfFuncsToRunOnToggleOut;
    end
    
    methods
        function p = FunctionExecutingToggleGroup(structOfButtonHandles, ...
                structOfFuncsToRunOnToggleTo, structOfFuncsToRunOnToggleOut)
            p = p@dentist.utils.MutuallyExclusiveToggleGroup(structOfButtonHandles);
            p.structOfFuncsToRunOnToggleTo = structOfFuncsToRunOnToggleTo;
            p.structOfFuncsToRunOnToggleOut = structOfFuncsToRunOnToggleOut;
        end
    end
    
    methods (Access = protected)
        function doOnToggleTo(p, buttonName)
            funcToRun = p.structOfFuncsToRunOnToggleTo.(buttonName);
            funcToRun();
        end
        function doOnToggleOutOf(p, buttonName)
            funcToRun = p.structOfFuncsToRunOnToggleOut.(buttonName);
            funcToRun();
        end
    end
    
end

