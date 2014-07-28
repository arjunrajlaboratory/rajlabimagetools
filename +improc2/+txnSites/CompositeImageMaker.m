classdef CompositeImageMaker < handle
    
    properties (Access = private)
        intronImageHolder
        exonImageHolder
        dapiImageHolder
        paramsForComposite
    end
    
    methods
        function p = CompositeImageMaker(exonImageHolder, ...
                intronImageHolder, dapiImageHolder, paramsForComposite)
            
            p.intronImageHolder = intronImageHolder;
            p.exonImageHolder = exonImageHolder;
            p.dapiImageHolder = dapiImageHolder;
            p.paramsForComposite = paramsForComposite;
        end
        
        function img = getImage(p)
            exonImg = p.exonImageHolder.getImage();
            exonImg = exonImg * p.paramsForComposite.getValue('exonMultiplier');
            exonImg = min(exonImg, 1);
            intronImg = p.intronImageHolder.getImage();
            intronImg = intronImg * p.paramsForComposite.getValue('intronMultiplier');
            intronImg = min(intronImg, 1);
            img = cat(3, intronImg, exonImg, p.dapiImageHolder.getImage()/2);
        end        
    end 
end

