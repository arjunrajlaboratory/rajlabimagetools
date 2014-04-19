function controls = launchObjectGroupingGUI(nameOfGroupingAnnotation, dirPathOrAnArrayCollection)
    controls = struct();
    
    if nargin < 2
        dirPathOrAnArrayCollection = pwd;
    end
    if nargin < 1
        nameOfGroupingAnnotation = 'group';
        fprintf('No group number annotation name specified. Defaulting to ''group''\n')
    end
    
    browsingTools = improc2.launchImageObjectBrowsingTools(dirPathOrAnArrayCollection);
    
    if ~ismember(nameOfGroupingAnnotation, browsingTools.annotations.itemNames)
        userOKWithAddingItems = queryIfUserWantsToAddGroupingAnnotation(nameOfGroupingAnnotation);
        if ~userOKWithAddingItems
            fprintf('Quitting...\n')
            return;
        end
        addGroupingAnnotationToAllObjects(dirPathOrAnArrayCollection, nameOfGroupingAnnotation)
        browsingTools.refresh();
    end
    
    imObGroupings = improc2.utils.ImageObjectsGroupings(...
        browsingTools.navigator, ...
        browsingTools.annotations, ...
        nameOfGroupingAnnotation);
    
    imObGroupingTool = improc2.utils.Grouper(imObGroupings);
    imObGroupingTool.assignGroupsToItemsAssignedToNaN();
    
    figH = figure(); axH = axes('Parent', figH, 'XTick', [] , 'YTick', []);
    axis(axH, 'equal');
    set(figH, 'ColorMap', bone(32));
    
    maskImageProvider = improc2.utils.MasksImageForAllObjectsInArray(...
        browsingTools.objectHandle, ...
        browsingTools.navigator);
    
    firstMask = browsingTools.objectHandle.getMask();
    width = size(firstMask, 2);
    height = size(firstMask, 1);
    viewport = dentist.utils.ImageViewport(width, height);
    viewportHolder = dentist.utils.ViewportHolder(viewport);
    
    maskImageDisplayer = improc2.utils.ImageDisplayer(axH, ...
        maskImageProvider, viewportHolder);
    maskImageDisplayer.draw();
    
    
    imObCentroidsSource = improc2.utils.ImageObjectsCentroidsSource(...
        browsingTools.navigator, browsingTools.objectHandle);
    
    groupDisplayer = improc2.utils.GroupedCentroidsDisplayer(...
        axH, imObCentroidsSource, imObGroupings);
    
    groupDisplayer.draw();
    
    polygonBasedGroupingTool = improc2.utils.PolygonBasedCentroidsGrouper(...
        imObGroupingTool, imObCentroidsSource);
    polygonBasedGroupingTool.addActionAfterGrouping(groupDisplayer, @draw);
    
    takesAddPolygonRequestAndGroupsByThatPolygon = ...
        improc2.utils.PolygonAddableFromPolygonGrouper(polygonBasedGroupingTool);
    
    mouseGroupingTool = dentist.utils.PolygonAddingMouseInterpreter(...
        takesAddPolygonRequestAndGroupsByThatPolygon);
    mouseGroupingTool.wireToFigureAndAxes(figH, axH);
    
    browsingTools.navigator.addActionAfterMovingToNewArray(...
        imObGroupingTool, @assignGroupsToItemsAssignedToNaN);
    browsingTools.navigator.addActionAfterMovingToNewArray(...
        maskImageDisplayer, @draw);
    browsingTools.navigator.addActionAfterMovingToNewArray(...
        groupDisplayer, @draw);
    
    improc2.WholeArrayNavigatorGUI(browsingTools.navigator);
end

function addGroupingAnnotationToAllObjects(dirPathOrAnArrayCollection, nameOfGroupingAnnotation)
    fprintf('Adding group annotation to all objects...\n')
    annotationsAdder = improc2.launchAnnotationsAdder(dirPathOrAnArrayCollection);
    annotationsAdder.specifyNewNumericItem(nameOfGroupingAnnotation)
    annotationsAdder.addNewItemsToAllObjectsAndQuit()
end

function runAsIs = queryIfUserWantsToAddGroupingAnnotation(groupAnnotName)
    msg = sprintf('*!* Add grouping annotation ''%s'' to all objects? (y/n) ', groupAnnotName);
    yn = input(msg,'s');
    fprintf('\n');
    userPressedReturn = isempty(yn);
    if userPressedReturn
        yn = 'n'; 
    end
    runAsIs = any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}));
end
