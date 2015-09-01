classdef VolumeFromRnaPoints < improc2.interfaces.ProcessedData
    
    properties
        needsUpdate = true
    end
    properties (SetAccess = private)
        % Radius = 35 for CRL, 20 for A549
        radius = 35
        planeSpacing
        xyPixelWidth
        volumeWithNuc
        volume
        volumeRealUnits
        cellContour
    end
    
    properties (Constant = true)
        dependencyClassNames = {...
            'improc2.interfaces.MaskContainer', ...
            'improc2.interfaces.MaskContainer', ...
            'improc2.interfaces.SpotsProvider'};
        dependencyDescriptions = {...
            'has the object''s mask', ...
            'has nuclear mask', ...
            'spots'};
    end
    
    methods
        function pData = VolumeFromRnaPoints(planeSpacing,xyPixelWidth)
            pData.planeSpacing = planeSpacing;
            pData.xyPixelWidth = xyPixelWidth;
        end
        function pDataAfterProcessing = run(pData, imObjMaskContainer, ...
                nuclearMaskContainer, spotsProvider)
            
            croppedMask = imObjMaskContainer.mask;
            nuclearMask = nuclearMaskContainer.mask;
            
            [Is, Js, Ks] = getSpotCoordinates(spotsProvider);
            x = Js;
            y = Is;
            z = Ks;
            
            expFactor = 1;
            [vOrig, cellTopOrig, cellBottomOrig] = ...
                improc2.volume.findVol_Expand2(croppedMask, nuclearMask, ...
                x, y, z, expFactor, pData.radius);
            
            [xf, yf, zf] = improc2.volume.fillVol2(croppedMask, z, cellTopOrig, cellBottomOrig, numel(x), 1);
            
            [vFake cellTopFake cellBottomFake] = ...
                improc2.volume.findVol_Expand2(croppedMask, nuclearMask, ...
                xf, yf, zf, 1, pData.radius);
            
            if vFake < vOrig
                begInt = 1;
            else % This is a hack, I don't expect this to happen...
                disp('fake volume is larger than expected');
                begInt = 0.5;
            end
            
            expFactor = vOrig/vFake;
            
            while true
                [xf yf zf] = improc2.volume.fillVol2(croppedMask, z, cellTopOrig, cellBottomOrig, numel(x), expFactor);
                
                [vFake cellTopFake cellBottomFake] = improc2.volume.findVol_Expand2(croppedMask, ...
                    nuclearMask, xf, yf, zf, expFactor, pData.radius);
                
                if vFake > vOrig
                    endInt = expFactor;
                    break;
                else
                    expFactor = 1.1*expFactor;
                end
            end
            
            
            expFactor = (begInt + endInt)/2;
            while true
                [xf, yf, zf] = improc2.volume.fillVol2(croppedMask, z, ...
                    cellTopOrig, cellBottomOrig, numel(x), expFactor);
                
                [vFake, cellTopFake, cellBottomFake] = ...
                    improc2.volume.findVol_Expand2(croppedMask, nuclearMask, ...
                    xf, yf, zf, expFactor, pData.radius);
                
                if abs(1-vOrig/vFake)<0.01
                    break;
                elseif vOrig/vFake > 1 %this means our expFactor is too small
                    begInt = expFactor; %make this the beginning of our interval
                    expFactor = (endInt+begInt)/2; %increase expFactor
                else %this means our expFactor is too large
                    endInt = expFactor; %make this the end of the interval
                    expFactor = (endInt+begInt)/2;
                end
            end
            
            cellTopReal = imresize(cellTopOrig,expFactor);
            cellTopReal = cellTopReal*expFactor;
            cellBottomReal = imresize(cellBottomOrig,expFactor);
            cellBottomReal = cellBottomReal*expFactor;
            
            resizedMask = imresize(croppedMask, expFactor);
            resizedNuclearMask = imresize(nuclearMask, expFactor);
            
            height = cellTopReal-cellBottomReal;
            height(isnan(height)) = 0;
            height(~resizedMask) = 0;
            volumeWithNuc = sum(height(:));
            height(resizedNuclearMask) = 0;
            volume = sum(height(:));
            volumeRealUnits = volume * pData.xyPixelWidth^2 * pData.planeSpacing;
            
            cellTop = cellTopReal;
            %cellTop(~resizedMask) = 0;
            
            pData.volumeWithNuc = volumeWithNuc;
            pData.volumeRealUnits = volumeRealUnits;
            pData.volume = volume;
            pData.cellContour = cellTop;
            pDataAfterProcessing = pData;
        end
        function showShell(pDataAfterProcessing)
            celltop2 = medfilt2(pDataAfterProcessing.cellContour, [20,20]);
            ti = 1:5:size(celltop2,1);
            tf = 1:5:size(celltop2,2);
            [qx,qy] = meshgrid(tf,ti);
            cthalf = celltop2(1:5:end,1:5:end);
            figure;
            colormap bone;
            mesh(qx,qy,cthalf);
        end
    end 
end

