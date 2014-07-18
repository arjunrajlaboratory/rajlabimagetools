classdef TotalIntensityProcessedData < improc2.interfaces.ProcessedData
    
    properties
        needsUpdate = true;
    end
    
    properties (Constant = true)
        dependencyClassNames = {'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'imageSource'};
    end
    
    properties (Dependent = true)
        summedIntensity
    end
    
    properties (Access = private)
        storedSummedIntensity
    end
    
    
    methods
        function pData = TotalIntensityProcessedData()
        end
        
        function intensity = get.summedIntensity(pData)
            intensity = pData.storedSummedIntensity;
        end
        
        function pDataAfterProcessing = run(pData, channelStackContainer)
            
            croppedimg = channelStackContainer.croppedImage;
            objmask = channelStackContainer.croppedMask;
            
            sz = size(croppedimg);
            intensityAtPlane = zeros([1 sz(3)]);
            for i = 1:sz(3)
                planeIm = croppedimg(:,:,i);
                planeIm = double(planeIm) .* double(objmask);
                intensityAtPlane(i) = sum(planeIm(:));
            end
            pData.storedSummedIntensity = max(intensityAtPlane);
            pDataAfterProcessing = pData;
        end        
    end
    
end

