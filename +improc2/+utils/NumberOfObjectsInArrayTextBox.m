classdef NumberOfObjectsInArrayTextBox < handle
    
    properties (Access = private)
        navigator
        textbox
    end
    
    methods
        function p = NumberOfObjectsInArrayTextBox(textbox, navigator)
            p.textbox = textbox;
            p.navigator = navigator;
        end
        function draw(p)
            set(p.textbox, 'String', sprintf('Obj:\n of %d', ...
                p.navigator.numberOfObjectsInCurrentArray))
        end
    end
end

