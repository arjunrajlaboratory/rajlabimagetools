classdef Channel < improc2.SingleChannelProcManager
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filename    % string with image filename (e.g. 'tmr001.stk')
        metadata
    end
    
    
    methods
        function p = Channel(filename, varargin)
            if nargin < 1 
                error('improc2:BadArguments','filename must be given')
            end
            p = p@improc2.SingleChannelProcManager(varargin{:});
            p.filename = filename;
        end
        
        function img = getImage(p)
           img = p.processor.getImage();
        end
    end
    
end

