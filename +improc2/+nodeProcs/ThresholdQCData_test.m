improc2.tests.cleanupForTests;

x = improc2.nodeProcs.ThresholdQCData();

assert(~isa(x, 'improc2.interfaces.ProcessedData'))
assert(isa(x, 'improc2.interfaces.NodeData'))

assert(x.needsUpdate)
assert(~x.reviewed)

assert(isequal(...
    sort(x.dependencyClassNames), ...
    sort({'improc2.interfaces.NodeData'})))

% reviewed is an alias for needsUpdate
x.reviewed = true;
assert(x.reviewed)
assert(~x.needsUpdate)

x.needsUpdate = true;
assert(~ x.reviewed)

assert(strcmp(x.hasClearThreshold, 'NA'))

x.hasClearThreshold = 'yes';
assert(strcmp(x.hasClearThreshold, 'yes'))

x.hasClearThreshold = 'no';
assert(strcmp(x.hasClearThreshold, 'no'))

improc2.tests.shouldThrowError( @() setfield(x, 'hasClearThreshold', 'notYesOrNOorNA'))