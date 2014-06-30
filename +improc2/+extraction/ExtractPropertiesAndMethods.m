function [] = ExtractPropertiesAndMethods(dirPathOrAnArrayCollection)

% inMemoryCollection = improc2.tests.data.collectionOfProcessedDAGObjects();
% browsingTools = improc2.launchImageObjectBrowsingTools(inMemoryCollection);




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

browsingTools = improc2.launchImageObjectBrowsingTools(arrayCollection);
nodeLabels = browsingTools.objectHandle.getLabelsOfNodesWithData();



directlyExtractable = {'nodeLabel','PropertyOrMethod','nameOfPropertyOrMethod','classOfData'};
indirectlyExtractable = {'nodeLabel','PropertyOrMethod','nameOfPropertyOrMethod','classOfData'};
vecOfLabels = {'string' 'scalar' 'logical'};

for i = 1:numel(nodeLabels)    
    
    
    propertiesOfData = properties(browsingTools.objectHandle.getData(char(nodeLabels{i})));
    methodsOfData = methods(browsingTools.objectHandle.getData(char(nodeLabels{i})));

    classNameWithoutFullPackageAddress = regexp(class(browsingTools.objectHandle.getData(char(nodeLabels{i}))), '[^.]*$', 'match');
    listNoConstructor = methodsOfData(~strcmp(methodsOfData, classNameWithoutFullPackageAddress));
    listNoConstructorNoRun = listNoConstructor(~strcmp(listNoConstructor, 'run'));

    
    


    for j = 1:numel(propertiesOfData)
        extractedData = browsingTools.objectHandle.getData(char(nodeLabels{i})).(propertiesOfData{j});

        isAString = ischar(extractedData);
        isNumericScalar = isnumeric(extractedData) && isscalar(extractedData);
        isLogicalScalar = islogical(extractedData) && isscalar(extractedData);

        if (isAString || isNumericScalar || isLogicalScalar)
            type = vecOfLabels{find([isAString isNumericScalar isLogicalScalar])};
            directlyExtractable = [directlyExtractable ; {nodeLabels{i} 'property' propertiesOfData{j} type}];
        else
            indirectlyExtractable = [indirectlyExtractable ; {nodeLabels{i} 'property' propertiesOfData{j} class(extractedData)}];
        end
    end

    for j = 1:numel(listNoConstructorNoRun)
        extractedFunction = str2func(listNoConstructorNoRun{j});
        extractedData = extractedFunction(browsingTools.objectHandle.getData(char(nodeLabels{i})));

        isAString = ischar(extractedData);
        isNumericScalar = isnumeric(extractedData) && isscalar(extractedData);
        isLogicalScalar = islogical(extractedData) && isscalar(extractedData);

        if (isAString || isNumericScalar || isLogicalScalar)
            type = vecOfLabels{find([isAString isNumericScalar isLogicalScalar])};
            directlyExtractable = [directlyExtractable ; {nodeLabels{i} 'method' listNoConstructorNoRun{j} type}];
        else
            indirectlyExtractable = [indirectlyExtractable ; {nodeLabels{i} 'method' listNoConstructorNoRun{j} class(extractedData)}];
        end
    end

end

assignin('base', 'directlyExtractable', directlyExtractable)
assignin('base', 'indirectlyExtractable', indirectlyExtractable)

end




