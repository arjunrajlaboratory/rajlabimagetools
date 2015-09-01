classdef CompositeImageMaker < handle
    %Object to handle the creation of composite images. StringFlag specifies
    %the channel selected by the popupmenu (either introns only, exons only or
    %both)
    properties (Access = private)
        intronImageHolder
        exonImageHolder
        dapiImageHolder
        paramsForComposite
        stringFlag
    end
    
    methods
        function p = CompositeImageMaker(exonImageHolder, ...
                intronImageHolder, dapiImageHolder, paramsForComposite, stringFlag)
            p.stringFlag = stringFlag;
            p.intronImageHolder = intronImageHolder;
            p.exonImageHolder = exonImageHolder;
            p.dapiImageHolder = dapiImageHolder;
            p.paramsForComposite = paramsForComposite;
        end
        
        function img = getImage(p)
            if(strcmp(p.stringFlag, 'Both'))
                exonImg = p.exonImageHolder.getImage();
                exonImg = exonImg * p.paramsForComposite.getValue('exonMultiplier');
                exonImg = min(exonImg, 1);
                intronImg = p.intronImageHolder.getImage();
                intronImg = intronImg * p.paramsForComposite.getValue('intronMultiplier');
                intronImg = min(intronImg, 1);
                img = cat(3, intronImg, exonImg, p.dapiImageHolder.getImage()/2);
            else
                %if it specifies only one channel, have the Exon image
                %maker handle it, since it is already built to do one
                %channel
                if(strcmp(p.stringFlag, 'Introns'))
                    IntronCompImMaker = improc2.txnSites2.CompositeExonImageMaker(p.intronImageHolder, ...
                        p.dapiImageHolder, p.paramsForComposite);
                    img = IntronCompImMaker.getImage();
                else
                    ExonCompImMaker = improc2.txnSites2.CompositeExonImageMaker(p.exonImageHolder, ...
                        p.dapiImageHolder, p.paramsForComposite);
                    img = ExonCompImMaker.getImage();
                end
            end
        end
    end
end


