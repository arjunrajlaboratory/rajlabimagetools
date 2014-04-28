improc2.tests.cleanupForTests;

x = improc2.dataNodes.DirectedAcyclicGraph();
assert(numberOfNodes(x) == 0)

node1 = improc2.dataNodes.Node();
node1.label = 'a';

x = addNode(x, node1);
assert(numberOfNodes(x) == 1)

node1InGraph = x.nodes{1};
assert(isequal(node1InGraph.label, 'a'))

node2 = improc2.dataNodes.Node(); 
node2.label = 'b';
node2.data = 57;
x = addNode(x, node2);

node3 = improc2.dataNodes.Node();
node3.label = 'f(a)';
node3.dependencyNodeLabels = {'a'};
x = addNode(x, node3);

node4 = improc2.dataNodes.Node();
node4.label = 'g(b, f(a))';
node4.dependencyNodeLabels = {'b', 'f(a)'};
x = addNode(x, node4);

node5 = improc2.dataNodes.Node();
node5.label = 'c';
x = addNode(x, node5);

node6 = improc2.dataNodes.Node();
node6.label = 'f(c)';
node6.dependencyNodeLabels = {'c'};

node7 = improc2.dataNodes.Node();
node7.label = 'h(c)';
node7.dependencyNodeLabels = {'c'};

x = addNode(x, node6);
x = addNode(x, node7);

assert(isequal(numberOfNodes(x), 7))
assert(isequal(x.nodes{1}.childNodeLabels, {'f(a)'}))
assert(isequal(x.nodes{2}.childNodeLabels, {'g(b, f(a))'}))
assert(isequal(x.nodes{3}.childNodeLabels, {'g(b, f(a))'}))
assert(isempty(x.nodes{4}.childNodeLabels))
assert(isequal(x.nodes{5}.childNodeLabels, {'f(c)', 'h(c)'}))
assert(isempty(x.nodes{6}.childNodeLabels))
assert(isempty(x.nodes{7}.childNodeLabels))

expectedConnectivity = zeros(numberOfNodes(x));
expectedConnectivity(3,1) = 1;
expectedConnectivity(4, [2,3]) = 1;
expectedConnectivity(6,5) = 1;
expectedConnectivity(7,5) = 1;

assert(isequal(x.childVsParentConnectivity, expectedConnectivity))
assert(isequal(x.labels, {node1.label, node2.label, node3.label, ...
    node4.label, node5.label, node6.label, node7.label}))

nodeWithConflictingLabel = improc2.dataNodes.Node();
nodeWithConflictingLabel.label = node6.label;
improc2.tests.shouldThrowError(@() addNode(x, nodeWithConflictingLabel), 'improc2:LabelConflict')

extractedNode = getNodeByLabel(x, 'b');
assert(extractedNode.data == node2.data)

improc2.tests.shouldThrowError(@() getNodeByLabel(x, 'z'), 'improc2:NodeNotFound')

foundNodes = findAllNodesMatchingCondition(x, 'a', @(node) strcmp(node.label, 'g(b, f(a))')); 
assert(length(foundNodes) == 1)
assert(strcmp(foundNodes{1}.label, 'g(b, f(a))'))

foundNodes = findAllNodesMatchingCondition(x, 'c', @(node) strcmp(node.label, 'g(b, f(a))')); 
assert(isempty(foundNodes))

foundNodes = findAllNodesMatchingCondition(x, 'a', @(node) true); 
assert(length(foundNodes) == 3)
foundNodeLabels = cellfun(@(node) node.label, foundNodes, 'UniformOutput', false);
assert(ismember('a', foundNodeLabels))
assert(ismember('f(a)', foundNodeLabels))
assert(ismember('g(b, f(a))', foundNodeLabels))

foundNodes = findAllNodesMatchingCondition(x, 'c', @(node) true); 
assert(length(foundNodes) == 3)
foundNodeLabels = cellfun(@(node) node.label, foundNodes, 'UniformOutput', false);
assert(ismember('c', foundNodeLabels))
assert(ismember('f(c)', foundNodeLabels))
assert(ismember('h(c)', foundNodeLabels))

foundNodes = findShallowestNodesMatchingCondition(x, 'c', @(node) true); 
assert(length(foundNodes) == 1)
foundNodeLabels = cellfun(@(node) node.label, foundNodes, 'UniformOutput', false);
assert(ismember('c', foundNodeLabels))

foundNodes = findShallowestNodesMatchingCondition(x, 'a', ...
    @(node) strcmp(node.label, 'g(b, f(a))'));
assert(length(foundNodes) == 1)
assert(strcmp(foundNodes{1}.label, 'g(b, f(a))'))

view(x)