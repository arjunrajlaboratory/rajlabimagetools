improc2.tests.cleanupForTests;

rnaImg = zeros(10,10);
rnaImg(3,5) = 1;
rnaImg(8,4) = 0.8;
rnaImg(4,7) = 0.4;
rnaImg(9,2) = 0.9;

dapiImg = zeros(10,10);
dapiImg(3:7, 3:7) = 1;

transImg = zeros(10,10);
transImg(1,:) = 1;
transImg(10,:) = 1;
transImg(:,1) = 1;
transImg(:,10) = 1;

rnaHolder = improc2.tests.MockImageHolder(rnaImg);
dapiHolder = improc2.tests.MockImageHolder(dapiImg);
transHolder = improc2.tests.MockImageHolder(transImg);

paramsStruct = struct();
paramsStruct.showDapi = improc2.TypeCheckedLogical(false);
paramsStruct.showTrans = improc2.TypeCheckedLogical(false);
paramItems = improc2.utils.FieldsBasedItemCollectionHandle(paramsStruct);
paramsHolder = improc2.utils.NamedValuesAndChoicesFromItemCollection(paramItems);

x = improc2.thresholdGUI.CompositeImageMaker(rnaHolder, dapiHolder, ...
    transHolder, paramsHolder);

img = x.getImage();
expectedIm = cat(3, rnaImg, rnaImg, rnaImg);
assert(isequal(img, expectedIm))

paramsHolder.setValue('showDapi', true)
img = x.getImage();
expectedIm = cat(3, rnaImg, rnaImg, rnaImg);
expectedIm(:,:,3) = min(1, expectedIm(:,:,3) + dapiImg / 2);
expectedIm(:,:,1) = min(1, expectedIm(:,:,1) + dapiImg / 2);
assert(isequal(img, expectedIm))

paramsHolder.setValue('showTrans', true)
img = x.getImage();
expectedIm = cat(3, rnaImg, rnaImg, rnaImg);
expectedIm(:,:,3) = min(1, expectedIm(:,:,3) + dapiImg / 2);
expectedIm(:,:,1) = min(1, expectedIm(:,:,1) + dapiImg / 2);
expectedIm(:,:,2) = min(1, expectedIm(:,:,2) + transImg / 2);
expectedIm(:,:,1) = min(1, expectedIm(:,:,1) + transImg / 2);
assert(isequal(img, expectedIm))

imshow(img, 'InitialMagnification', 'fit')

paramsHolder.setValue('showDapi', false)
img = x.getImage();
expectedIm = cat(3, rnaImg, rnaImg, rnaImg);
expectedIm(:,:,2) = min(1, expectedIm(:,:,2) + transImg / 2);
expectedIm(:,:,1) = min(1, expectedIm(:,:,1) + transImg / 2);
assert(isequal(img, expectedIm))
