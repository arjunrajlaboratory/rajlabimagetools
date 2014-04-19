classdef ObjectNumberTextBox < handle
    
    properties (Access = private)
        textbox
        navigator
    end
    
    methods
        function p = ObjectNumberTextBox(textbox, navigator)
            p.textbox = textbox;
            p.navigator = navigator;
            set(p.textbox, 'CallBack', @(varargin) p.callback())
        end
        
        function draw(p)
            objNum = p.navigator.currentObjNum;
            set(p.textbox, 'String', num2str(objNum))
        end
    end
    
    methods (Access = private)
        function callback(p)
            try
                requestedObj = str2num(get(p.textbox, 'String'));
                p.navigator.tryToGoToObj(requestedObj);
            catch err
                p.draw()
                rethrow(err)
            end
        end
    end
end

