improc2.tests.cleanupForTests;

obj = struct();

cyIm = eye(2,2);
tmrIm = 2 * eye(2,2);
dapiIm = 3 * eye(2,2);

obj.channels = struct('cy',struct(), 'tmr',struct(), 'dapi', struct());
obj.channels.cy.processor = improc2.tests.MockImageHolder(cyIm);
obj.channels.tmr.processor = improc2.tests.MockImageHolder(tmrIm);
obj.channels.dapi.processor = improc2.tests.MockImageHolder(dapiIm);

mockObjHolder = improc2.utils.ObjectHolder();
mockObjHolder.obj = obj;

objHandle = improc2.utils.HandleToLegacyimage_object(mockObjHolder);

x = improc2.utils.ImageHolderFromImageObjectHandle(objHandle, 'cy');

assert(isequal(x.getImage(), cyIm))

x = improc2.utils.ImageHolderFromImageObjectHandle(objHandle, 'dapi');

assert(isequal(x.getImage(), dapiIm))

modifiedDapiIm = 5 * eye(2,2);
mockObjHolder.obj.channels.dapi.processor = ...
    improc2.tests.MockImageHolder(modifiedDapiIm);

assert(isequal(x.getImage(), modifiedDapiIm))
