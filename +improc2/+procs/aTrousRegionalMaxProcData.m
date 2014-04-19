classdef aTrousRegionalMaxProcData < improc2.procs.RegionalMaxProcData
    % An object that applies an aTrousFilter prior regional-maxima based spot finding.
    
    methods
        function p = aTrousRegionalMaxProcData(varargin)
            p.filterParams = improc2.aTrousFilterParams(struct('sigma',0.5,'numLevels',3));
            p.imageFilterFunc = @improc2.utils.applyATrousImageFilter;
            
            p.description = sprintf(...
                ['1) aTrous wavelet decomposition\n',...
                '2) Reconstruct image with detail bands only\n',...
                '3) Find all regional maxima\n',...
                '4) Auto threshold on intensity']);
            
            ip = inputParser;
            ip.addOptional('filterParams', struct(), @isstruct);
            ip.parse(varargin{:});


            p.filterParams = p.filterParams.replaceParams( ip.Results.filterParams );
        end 
    end
end

