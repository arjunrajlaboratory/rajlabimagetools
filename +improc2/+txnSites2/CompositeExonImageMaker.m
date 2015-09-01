classdef CompositeExonImageMaker < handle
%CompositeImageMaker object fo construction of images containing only one 
%channel and the dapi channel
    properties (Access = private)
        exonImageHolder
        dapiImageHolder
        paramsForComposite
    end
    
    methods
        function p = CompositeExonImageMaker(exonImageHolder, ...
                dapiImageHolder, paramsForComposite)
            
            p.exonImageHolder = exonImageHolder;
            p.dapiImageHolder = dapiImageHolder;
            p.paramsForComposite = paramsForComposite;
        end
        
        function img = getImage(p)
            %create RGB dapi image - ratios give dapi a conventional purple
            %color
            dapiImg = zeros(size(p.dapiImageHolder.getImage(), 1), size(p.dapiImageHolder.getImage(), 2), 3);
            dapiImg(:,:,1) = (171/255)*p.dapiImageHolder.getImage();
            dapiImg(:,:,2) = (153/255)*p.dapiImageHolder.getImage();
            dapiImg(:,:,3) = (242/255)*p.dapiImageHolder.getImage();
            %Create RGB spot image with gray/white spots
            exonImg = zeros(size(p.exonImageHolder.getImage(), 1), size(p.exonImageHolder.getImage(), 2), 3);
            exonImg(:,:,1) = p.exonImageHolder.getImage();
            exonImg(:,:,2) = p.exonImageHolder.getImage();
            exonImg(:,:,3) = p.exonImageHolder.getImage();
            %Combine the images
            img = exonImg/2 + dapiImg/2;
        end        
    end 
end

