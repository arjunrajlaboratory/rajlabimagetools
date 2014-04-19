function [ img, imgObjMask ] = getArgsForClassicProcessor( varargin )
% two input options:
% imgObj, channelName
% OR:
% (cropped)img, imgObjMask

errstring = 'Must provide two inputs.';

if nargin ~= 2
    error('improc2:BadArguments',errstring);
end
    
try
    objH = varargin{1};
    channelName = varargin{2};
    [img, imgObjMask] = improc2.getCroppedImgAndMaskFromObj(objH,channelName);
catch err
    if strcmp(err.identifier, 'improc2:BadArguments')
        errstring = [err.message, '\nOR:'];
    
        errstring = [errstring, '\nRun with args (img: numeric, mask: logical)'];
        if ~(isnumeric(varargin{1}) && islogical(varargin{2}))
            error('improc2:BadArguments',errstring);
        end
            
        img = varargin{1};
        imgObjMask = varargin{2};
        szimg = size(img(:,:,1));
        szmask = size(imgObjMask);
        errstring = [errstring, '\n\tAND: Arguments must be of compatible dimensions.'];
        if ~(length(szimg)==2 && length(szmask)==2)
            error('improc2:BadArguments',errstring);
        end
        errstring = [errstring, '\n\tAND: Arguments must be of compatible size.'];
        if ~(all(size(img(:,:,1)) == size(imgObjMask)))
            error('improc2:BadArguments',errstring);
        end
    else
        rethrow(err)
    end
end

end

