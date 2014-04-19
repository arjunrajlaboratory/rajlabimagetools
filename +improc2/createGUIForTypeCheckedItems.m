function guiHandles = createGUIForTypeCheckedItems(itemNames, itemClasses)
    
    guiHandles.figH = figure('Position',[400 150 280 130],...
        'NumberTitle','off',...
        'Toolbar','none',...
        'MenuBar','none',...
        'HandleVisibility', 'callback',...
        'Color',[0.247 0.247 0.247],...
        'Visible','on');

    numOfItems = length(itemNames);
    guiHandles.itemLabels = struct();
    guiHandles.itemControls = struct();
    
    for itemNum = 1:numOfItems
        itemName = itemNames{itemNum};
        itemClass = itemClasses{itemNum};
        [labelPosition, uicontrolPosition] = getNormalizedItemPositions(itemNum, numOfItems);
        guiHandles.itemLabels.(itemName) = uicontrol('Style', 'text', 'String', itemName, ...
            'Units', 'normalized', 'Position', labelPosition, 'Parent', guiHandles.figH, ...
            'HorizontalAlignment', 'center', ...
            'ForegroundColor',[1 1 1],...
            'BackgroundColor',[0.247 0.247 0.247]);
        extraArgs = {};
        switch itemClass
            case 'improc2.TypeCheckedLogical'
                extraArgs = {'Style', 'checkbox', 'String', ''};
            case 'improc2.TypeCheckedNumeric'
                extraArgs = {'Style', 'edit', 'String', ''};
            case 'improc2.TypeCheckedString'
                extraArgs = {'Style', 'edit', 'String', ''};
            case {'improc2.TypeCheckedFactor', 'improc2.TypeCheckedYesNoOrNA'}
                extraArgs = {'Style', 'popupmenu', 'String', 'empty'};
        end
        guiHandles.itemControls.(itemName) = uicontrol('Parent', guiHandles.figH, ...
            'Units', 'normalized', 'Position', uicontrolPosition, ...
            extraArgs{:});
    end
end

function [labelPosition, uicontrolPosition] = getNormalizedItemPositions(itemNum, numOfItems)
    bottomMargin = 0.1;
    topMargin = 0.1;
    leftMargin = 0.1;
    rightMargin = 0.1;
    betweenItemsRelativeMargin = 0.2;
    
    totalHeightForItems = 1 - topMargin - bottomMargin;
    totalHeightForItemsExcludingInterItemMargins = totalHeightForItems * ...
        (1 - betweenItemsRelativeMargin * (numOfItems - 1)/numOfItems);
    itemHeightExcludingInterItemMargin = ...
        totalHeightForItemsExcludingInterItemMargins / numOfItems;
    itemHeightIncludingMargin = itemHeightExcludingInterItemMargin / (1 - betweenItemsRelativeMargin);
    
    labelXPosition = leftMargin;
    overallItemWidth = 1 - leftMargin - rightMargin;
    labelWidth = overallItemWidth * 0.45;
    uicontrolXPosition = leftMargin + overallItemWidth * 0.5;
    uicontrolWidth = overallItemWidth * 0.45;
    
    yPosition = bottomMargin + (itemNum - 1) * itemHeightIncludingMargin;
    height = itemHeightExcludingInterItemMargin;
    
    labelPosition = [labelXPosition, yPosition, labelWidth, height];
    uicontrolPosition = [uicontrolXPosition, yPosition, uicontrolWidth, height];  
end

