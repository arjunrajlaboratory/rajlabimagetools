function convertCollectionFromStackBasedToDAGBased(...
    stackBasedCollection, destinationDAGBasedCollection, backupCollection)

    if nargin < 3
        backupCollection = improc2.utils.BlackHoleCollection();
    end

    for i = 1:length(stackBasedCollection)
        objArray = stackBasedCollection.getObjectsArray(i);
        backupCollection.setObjectsArray(objArray, i);
        convertedArray = convertStackBasedObjArrayToDAGBasedObjArray(objArray);
        destinationDAGBasedCollection.setObjectsArray(convertedArray, i);
    end
end

function newArray = convertStackBasedObjArrayToDAGBasedObjArray(objArray)
    newArray = improc2.dataNodes.GraphBasedImageObject.empty;
    for i = 1:length(objArray)
        newArray(end+1) = ...
            improc2.dataNodes.converters.stackBasedObjectToDAGBasedObject(objArray(i));
    end
end