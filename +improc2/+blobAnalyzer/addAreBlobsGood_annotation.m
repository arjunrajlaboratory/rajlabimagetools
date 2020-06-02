
tools = improc2.launchImageObjectTools;
while tools.iterator.continueIteration
  tools.annotationItemAdder.addItem('areBlobsGood', true)
  tools.iterator.goToNextObject()
end