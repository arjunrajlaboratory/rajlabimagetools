classdef aTrousRegionalMaxProcessedData_expansion < improc2.nodeProcs.RegionalMaxProcessedData
    % An object that applies an aTrousFilter prior regional-maxima based spot finding.
    
    methods
        function p = aTrousRegionalMaxProcessedData_expansion(varargin)
            p.filterParams = improc2.aTrousFilterParams(struct('sigma',1.0,'numLevels',4));
            p.imageFilterFunc = @improc2.utils.applyATrousImageFilter;
            
            ip = inputParser;
            ip.addOptional('filterParams', struct());
            ip.parse(varargin{:});

            p.filterParams = p.filterParams.replaceParams( ip.Results.filterParams );
        end 
    end
end

