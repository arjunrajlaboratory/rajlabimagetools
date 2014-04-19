dentist.tests.cleanupForTests;

x = dentist.utils.CentroidsDisplayerParametersHolder();

assert(x.get('circleRadius') == 60)
assert(strcmp(x.get('spotsOrCircles'), 'spots'))

x.set('circleRadius', 30)
assert(x.get('circleRadius') == 30)
assert(strcmp(x.get('spotsOrCircles'), 'spots'))

try
    x.set('circleRadii', 40)
    error('Expected error')
catch err
    if strcmp(err.message, 'Expected error')
        rethrow(err)
    end
end

x.set('spotsOrCircles', 'circles', 'circleRadius', 50)
assert(x.get('circleRadius') == 50)
assert(strcmp(x.get('spotsOrCircles'), 'circles'))

try
    x.set('spotsOrCircles', 'NotSpotOrCircle')
    error('Expected error')
catch err
    if strcmp(err.message, 'Expected error')
        rethrow(err)
    end
end
