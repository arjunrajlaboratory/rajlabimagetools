classdef CompositeImageMaker < handle
    %Object to handle the creation of composite images. StringFlag specifies
    %the channel selected by the popupmenu (either introns only, exons only or
    %both)
    properties (Access = private)
        intronImageHolder
        exonImageHolder
        dapiImageHolder
        additionalImageHolders
        paramsForComposite
        stringFlag
    end
    
    methods
        function p = CompositeImageMaker(exonImageHolder, ...
                intronImageHolder, dapiImageHolder, additionalImageHolders, paramsForComposite, stringFlag)
            p.stringFlag = stringFlag;
            p.intronImageHolder = intronImageHolder;
            p.exonImageHolder = exonImageHolder;
            p.dapiImageHolder = dapiImageHolder;
            p.additionalImageHolders = additionalImageHolders;
            p.paramsForComposite = paramsForComposite;
        end
        
        function img = getImage(p)
            if(strcmp(p.stringFlag, 'Introns & Exons'))
                exonImg = p.exonImageHolder.getImage();
                exonImg = exonImg * p.paramsForComposite.getValue('exonMultiplier');
                exonImg = min(exonImg, 1);
                intronImg = p.intronImageHolder.getImage();
                intronImg = intronImg * p.paramsForComposite.getValue('intronMultiplier');
                intronImg = min(intronImg, 1);
                img = cat(3, intronImg, exonImg, p.dapiImageHolder.getImage()/2);
            elseif(strcmp(p.stringFlag, 'Introns'))
                %if it specifies only one channel, have the Exon image
                %maker handle it, since it is already built to do one
                %channel
                IntronCompImMaker = improc2.txnSites2.CompositeExonImageMaker(p.intronImageHolder, ...
                    p.dapiImageHolder, p.paramsForComposite);
                img = IntronCompImMaker.getImage();
            elseif(strcmp(p.stringFlag, 'Others'))

            elseif(strcmp(p.stringFlag, 'Exons'))
                ExonCompImMaker = improc2.txnSites2.CompositeExonImageMaker(p.exonImageHolder, ...
                    p.dapiImageHolder, p.paramsForComposite);
                img = ExonCompImMaker.getImage();
            else
                if (~isempty(p.additionalImageHolders))
                    for i = 1:length(p.additionalImageHolders)
                        if(strcmp(p.stringFlag, p.additionalImageHolders(i).channelName))
                            additionalImCompMaker = improc2.txnSites2.CompositeExonImageMaker(...
                                p.additionalImageHolders(i), p.dapiImageHolder, p.paramsForComposite);
                            img = additionalImCompMaker.getImage();
                            
%                             additionalImgs(:, :, i) = p.additionalImageHolders(i).getImage();
%                             additionalImgs(:, :, i) = min(additionalImgs(:, :, i), 1);
                            break
                        end
                    end
                else
                    error('There are no other channels specified in the launchGUI command.')
                end
            end
        end
    end
end


