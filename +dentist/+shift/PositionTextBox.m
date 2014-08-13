classdef PositionTextBox < handle
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        textH
    end
    
    methods
        function p = PositionTextBox(textH)
            p.textH = textH;
        end
        function setPosition(p, row, col)
            text = [num2str(row),' - ',num2str(col),' (row - col)'];
            set(p.textH, 'String', text);
        end
    end
    
end

