classdef aTrousRegionalMaxProcessedData < improc2.nodeProcs.RegionalMaxProcessedData
    % An object that applies an aTrousFilter prior regional-maxima based spot finding.
    
    methods
        function p = aTrousRegionalMaxProcessedData(varargin)
            p.filterParams = improc2.aTrousFilterParams(struct('sigma',0.5,'numLevels',3));
            p.imageFilterFunc = @improc2.utils.applyATrousImageFilter;
            
            ip = inputParser;
            ip.addOptional('filterParams', struct(), @isstruct);
            ip.parse(varargin{:});

            p.filterParams = p.filterParams.replaceParams( ip.Results.filterParams );
        end 
    end
end

