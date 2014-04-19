classdef WaitBar < handle
    %UNTITLED12 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        waitbarH;
        actionDescriptionString = 'Working';
        unitName = '';
    end
    
    methods
        function p = WaitBar(actionDescriptionString, unitName)
            if nargin >= 1
                p.actionDescriptionString = actionDescriptionString;
            end
            if nargin >= 2
                p.unitName = unitName;
            end
        end
        
        function delete(p)
            delete(p.waitbarH)
        end
        
        function showProgress(p, barNumerator, barDenominator, ...
                stringNumerator, stringDenominator)
            if nargin == 3
                stringToShow = p.actionDescriptionString;
            elseif nargin == 5
                stringToShow = sprintf( '%s: %s %d of %d', ...
                    p.actionDescriptionString, ...
                    p.unitName, ...
                    stringNumerator, ...
                    stringDenominator);
            end
            
            fractionToShow = barNumerator / barDenominator;

            
            if isempty(p.waitbarH) || ~ishandle(p.waitbarH)
                p.waitbarH = waitbar(fractionToShow, stringToShow);
            else
                waitbar(fractionToShow, p.waitbarH, stringToShow);
            end
        end
            
    end
    
end

