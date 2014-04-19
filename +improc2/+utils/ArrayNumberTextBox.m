classdef ArrayNumberTextBox < handle
    
    properties (Access = private)
        textbox
        navigator
    end
    
    methods
        function p = ArrayNumberTextBox(textbox, navigator)
            p.textbox = textbox;
            p.navigator = navigator;
            set(p.textbox, 'CallBack', @(varargin) p.callback())
        end
        
        function draw(p)
            arrayNum = p.navigator.currentArrayNum;
            set(p.textbox, 'String', num2str(arrayNum))
        end
    end
    
    methods (Access = private)
        function callback(p)
            try
                requestedArray = str2num(get(p.textbox, 'String'));
                p.navigator.tryToGoToArray(requestedArray);
            catch err
                p.draw()
                rethrow(err)
            end
        end
    end
end

