dentist.tests.cleanupForTests;

cmap = jet(4);
coerceToUnitInterval = @(x) max(0, min(1, x));
scaleFunc = @(x) coerceToUnitInterval(x/max(x(:)));

x = dentist.utils.ValueToColorTranslator(scaleFunc, cmap);

values = [3 10]';

expectedInds = 1 + round((size(cmap,1)-1)*scaleFunc(values));

rgb = x.translateToRGB(values);
assert(all(all(rgb == cmap(expectedInds, :))))

%

cmap = hsv(16);
x.setColorMap(cmap)

expectedInds = 1 + round((size(cmap,1)-1)*scaleFunc(values));
rgb = x.translateToRGB(values);
assert(all(all(rgb == cmap(expectedInds, :))))

%

scaleFunc = @(x) ones(size(x));
x.setScalingFunction(scaleFunc)

expectedInds = 1 + round((size(cmap,1)-1)*scaleFunc(values));
rgb = x.translateToRGB(values);
assert(all(all(rgb == cmap(expectedInds, :))))

%

notAFunction = 'A string';
try
    x.setScalingFunction(notAFunction)
    error('Expected an error')
catch err
    if strcmp(err.message, 'Expected an error')
        rethrow(err)
    end
end

notAColorMap = [0 1; 1 0];
try
    x.setColorMap(notAColorMap)
catch err
    if strcmp(err.message, 'Expected an error')
        rethrow(err)
    end
end  
