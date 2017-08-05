% Generates an RGB image from the grayscale image inImage with the color
% theColor. e.g.,
% for red: makeColoredImage(myIm, [1 0 0]);
% for white: makeColoredImage(myIm, [1 1 1]);
% for blue: makeColoredImage(myIm, [0 0 1]);
% for purple: makeColoredImage(myIm, [1 0 1]);
% for cyan: makeColoredImage(myIm, [0 0.6797 0.9336]);
% for orange: makeColoredImage(myIm, [0.9648 0.5781 0.1172]);

function outRGB = makeColoredImage(inImage,theColor)

outRGB = zeros([size(inImage) 3]);

for i = 1:3
    outRGB(:,:,i) = inImage*theColor(i);
end