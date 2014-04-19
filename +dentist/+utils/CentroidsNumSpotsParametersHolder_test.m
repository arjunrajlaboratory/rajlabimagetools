dentist.tests.cleanupForTests;

x = dentist.utils.CentroidsNumSpotsParametersHolder();

assert(x.get('FontSize') == 12)
assert(x.get('xOffset') == 0)
assert(x.get('yOffset') == 0)

x.set('FontSize', 14)
assert(x.get('FontSize') == 14)
assert(x.get('xOffset') == 0)
assert(x.get('yOffset') == 0)

try
    x.set('circleRadii', 40)
    error('Expected error')
catch err
    if strcmp(err.message, 'Expected error')
        rethrow(err)
    end
end

x.set('xOffset',15, 'yOffset', -13)
assert(x.get('FontSize') == 14)
assert(x.get('xOffset') == 15)
assert(x.get('yOffset') == -13)

x.setToDefaults()
assert(x.get('FontSize') == 12)
assert(x.get('xOffset') == 0)
assert(x.get('yOffset') == 0)
