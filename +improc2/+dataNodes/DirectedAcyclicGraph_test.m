improc2.tests.cleanupForTests;

x = improc2.dataNodes.DirectedAcyclicGraph();
assert(numberOfNodes(x) == 0)

node1 = improc2.dataNodes.Node();
node1.label = 'a';

x = addNode(x, node1);
assert(numberOfNodes(x) == 1)

node1InGraph = x.nodes{1};
assert(isequal(node1InGraph.label, 'a'))
assert(isequal(node1InGraph.number, 1))

expectedConnectivity = [0];
assert(isequal(makeDependentsVsDependenciesMatrix(x), expectedConnectivity))

node2 = improc2.dataNodes.Node(); 
node2.label = 'b';
node2.data = 20;

node3 = improc2.dataNodes.Node();
node3.label = 'f(a)';
node3.dependencyNodeNumbers = [1];


node4 = improc2.dataNodes.Node();
node4.label = 'g(b, f(a))';
node4.dependencyNodeNumbers = [2,3];

node5 = improc2.dataNodes.Node();
node5.label = 'c';

node6 = improc2.dataNodes.Node();
node6.label = 'f(c)';
node6.dependencyNodeNumbers = 5;

x = addNode(x, node2);
x = addNode(x, node3);
x = addNode(x, node4);
x = addNode(x, node5);
x = addNode(x, node6);

assert(isequal(numberOfNodes(x), 6))
expectedConnectivity = zeros(numberOfNodes(x));
expectedConnectivity(3,1) = 1;
expectedConnectivity(4, [2,3]) = 1;
expectedConnectivity(6,5) = 1;

assert(isequal(makeDependentsVsDependenciesMatrix(x), expectedConnectivity))

assert(isequal(x.labels, {node1.label, node2.label, node3.label, ...
    node4.label, node5.label, node6.label}))

nodeWithConflictingLabel = improc2.dataNodes.Node();
nodeWithConflictingLabel.label = node6.label;
improc2.tests.shouldThrowError(@() addNode(x, nodeWithConflictingLabel),...
    'improc2:LabelConflict')

extractedNode = getNodeByLabel(x, node2.label);
assert(extractedNode.data == node2.data)

improc2.tests.shouldThrowError(@() getNodeByLabel(x, 'z'), ...
    'improc2:NodeNotFound')

view(x)