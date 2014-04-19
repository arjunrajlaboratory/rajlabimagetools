classdef MultiModeContraster < improc2.interfaces.ScaledImageContraster
    
    properties (Access = private)
        structOfContrasters
        currentContrasterName
    end
    
    properties (SetAccess = private)
        contrasterNames
    end
    
    methods
        function p = MultiModeContraster(structOfContrasters)
            p.structOfContrasters = structOfContrasters;
            p.contrasterNames = fields(structOfContrasters);
            p.currentContrasterName = p.contrasterNames{1};
        end
        
        function contrastedImg = contrast(p, varargin)
            contraster = p.structOfContrasters.(p.currentContrasterName);
            contrastedImg = contraster.contrast(varargin{:});
        end
        
        function setMode(p, requestedContrasterName)
            assert(ismember(requestedContrasterName, p.contrasterNames), ...
                'improc2:BadArguments', 'not the name of a stored contraster')
            p.currentContrasterName = requestedContrasterName;
        end
    end
end

