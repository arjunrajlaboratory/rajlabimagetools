classdef TransProcData < improc2.procs.ProcessorData & improc2.ImageDisplayer
    % An object that processes images like we usually process trans. Stores the middlePlane for display.
    
    properties (Access = private)
        middlePlane = [];
    end
    
    methods (Access = protected)
        
        function pDataAfterProcessing = runProcessor(pData, varargin)
            [img, ~] = improc2.getArgsForClassicProcessor(varargin{:});
            
            if ndims(img) == 3
                sz = size(img);
                middle = floor(sz(3)/2);
                pData.middlePlane = img(:,:,middle);
            elseif ndims(img) > 3
                error('Image Data must be 3 or less dimensions')
            else
                pData.middlePlane = img;
            end
            pData.middlePlane = scale(pData.middlePlane); 
            pDataAfterProcessing = pData;
        end
    end
    
    methods
        function pData = TransProcData()
            pData = pData@improc2.procs.ProcessorData('grabs representative plane for Trans image');
        end
        
        function img = getImage(pData, varargin)
            img = pData.middlePlane;
        end
    end
    
    
end

