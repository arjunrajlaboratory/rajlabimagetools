function controlStruct = launchImageObjectTools(dirPathOrAnArrayCollection)
    if nargin < 1
        dirPathOrAnArrayCollection = pwd;
    end
    
    if isa(dirPathOrAnArrayCollection, 'improc2.interfaces.ObjectArrayCollection')
        arrayCollection = dirPathOrAnArrayCollection;
    elseif ischar(dirPathOrAnArrayCollection)
        dirPath = dirPathOrAnArrayCollection;
        dataFiles = improc2.utils.ImageObjectDataFiles(dirPath);
        arrayCollection = improc2.utils.FileBasedImageObjectArrayCollection(...
            dataFiles);
    end
    
    objHolder = improc2.utils.ObjectHolder();
    navigator = improc2.utils.ImageObjectArrayCollectionNavigator(...
        arrayCollection, objHolder);
    
    if isa(objHolder.obj, 'improc2.dataNodes.GraphBasedImageObject')
        imgObjH = improc2.dataNodes.HandleToGraphBasedImageObject(objHolder);
        dataRegistrar = improc2.dataNodes.ProcessorRegistrarForGraphBasedImageObject(objHolder);
        annotationsHandle = improc2.ImageObjectAnnotationsHandle(objHolder);
        
    elseif isa(objHolder.obj, 'improc2.ImageObject')
        
        imgObjH = improc2.ImageObjectHandle(objHolder);
        dataRegistrar = improc2.ProcessorRegistrar(objHolder);
        annotationsHandle = improc2.ImageObjectAnnotationsHandle(objHolder);
        
    elseif isa(objHolder.obj, 'image_object')
        
        imgObjH = improc2.utils.HandleToLegacyimage_object(objHolder);
        dataRegistrar = ...
            improc2.utils.ProcessorRegistrarForLegacyimage_object(objHolder);
        annotationsHandle = ...
            improc2.Legacyimage_objectAnnotationsHandle(objHolder);
        
    end
    
    annotationValuesAndChoices = ...
        improc2.utils.NamedValuesAndChoicesFromItemCollection(annotationsHandle);
    
    annotations = ...
        improc2.utils.UISynchronizedNamedValuesAndChoices(annotationValuesAndChoices);
    
    annotationItemAdder = ...
        improc2.utils.TypeCheckedItemCollectionExtender(annotationsHandle);
    
    
    controlStruct = struct();
    controlStruct.navigator = navigator;
    controlStruct.iterator = improc2.ImageObjectIterator(navigator);
    controlStruct.objectHandle = imgObjH;
    controlStruct.dataRegistrar = dataRegistrar;
    controlStruct.annotations = annotations;
    controlStruct.annotationItemAdder = annotationItemAdder;
    controlStruct.refresh = @navigator.discardUnsavedChangesAndReload;
end

