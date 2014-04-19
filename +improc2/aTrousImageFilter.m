classdef aTrousImageFilter < improc2.ImageFilter
    % A concrete ImageFilter that, when applied, carries out the (undecimated) aTrousWaveletTransform with a gaussian kernel and then sums up a prescribed number of detail levels	

    properties
    end
    
    methods
        function p = aTrousImageFilter(filterParams)
            p.filterParams = improc2.aTrousFilterParams(...
                struct('sigma',0.5,'numLevels',3));
            if nargin ~= 0
                if isa(filterParams, 'improc2.aTrousFilterParams')
                    p.filterParams = filterParams;
                else
                    p.filterParams = p.filterParams.replaceParams( filterParams );
                end
            end
        end
        
        function imout = applyFilter(p, imin) 
            
            % aTrous filter. keep detail bands, remove approximation band
            [aTrous,Aj] = aTrousWaveletTransform(imin,...
                'numLevels',p.filterParams.numLevels,...
                'sigma',p.filterParams.sigma);
            
            % sum the detail bands to get a filtered image
            if ndims(imin) == 3  % 3D input image
                imout = sum(aTrous,4);
            else                % 2D input image
                imout = sum(aTrous,3);
            end
            
            clear aTrous; clear Aj;
        end

        
    end
    
end

