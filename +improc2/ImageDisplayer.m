classdef ImageDisplayer

    properties
    end
    
    methods
        
        function p = ImageDisplayer()
        end
        
        function img = getImage(p, varargin)
            img = 1;
        end
        
        function [imgH, axH] = plotImage(p,varargin)
            
            if nargin < 2
                fH = figure; axH = axes('Parent',fH);
            else
                axH = varargin{1};
            end
            
            if ~ishandle(axH) || ~strcmp('axes',get(axH,'Type'))
                error('The first argument must be an axes handle');
            end
            
            imgH = imshow(p.getImage(),'Parent',axH, ...
                'InitialMagnification', 'fit'); 
        end
    end
end

