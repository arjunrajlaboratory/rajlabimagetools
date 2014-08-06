classdef AxesManager < handle
    
    properties
        currentUL
        rightUL
        downUL
        downRightUL
        
        imageProvider
        selected
        order
        keyInterpreter
        panelInterpreter
        
        imgAx
    end
    
    methods
        function p = AxesManager(imgAx, imageProvider, keyInterpreter)
            p.imageProvider = imageProvider;
            p.currentUL = [1, 1];
            p.rightUL = [1, p.imageProvider.imageSize(2) + 1];
            p.downUL = [p.imageProvider.imageSize(1) + 1, 1];
            p.downRightUL = [p.imageProvider.imageSize(1) + 1,...
                p.imageProvider.imageSize(2) + 1];
            p.selected = [];
            p.keyInterpreter = keyInterpreter;
            p.order = [1,2,3,4];
            p.imgAx = imgAx;
        end
        function p = moveVertical(p, direction)
            if ~(direction == -1 || direction == 1)
               error('Only values of -1 or 1 permitted for direction argument'); 
            end
            p.shiftSelectedImages(1, direction);
            p.displayImage();
        end
        function p = moveHorizontal(p, direction)
            p.shiftSelectedImages(2, direction);
            p.displayImage();
        end
        function bringSelectedToFront(p)
            movedUpIndexes = [];
            for value = p.order
                if numel(find(p.selected == value)) ~= 0
                    movedUpIndexes(end + 1) = value;
                end
            end
            p.order(ismember(p.order, movedUpIndexes)) = [];
            p.order = [movedUpIndexes, p.order];
            p.displayImage();
        end
        function registerClick(p, point)
            selectedIndex = -1;
            indexToLoc = containers.Map([1,2,3,4],{p.currentUL, p.rightUL,...
                   p.downUL, p.downRightUL});
            for index = 1:numel(p.order)
                upperLeft = indexToLoc(index);
                rBegCanvas = max(1,upperLeft(1));
                cBegCanvas = max(1,upperLeft(2));
                canvasNumRows = p.imageProvider.imageSize(1) * 2;
                canvasNumCols = p.imageProvider.imageSize(2) * 2;
                rEndCanvas = min(upperLeft(1) + p.imageProvider.imageSize(1) - 1, canvasNumRows);
                cEndCanvas = min(upperLeft(2) + p.imageProvider.imageSize(2) - 1, canvasNumCols);
                if point(1) >= rBegCanvas && point(1) <= rEndCanvas &&...
                        point(2) >= cBegCanvas && point(2) <= cEndCanvas
                    selectedIndex = index;
                    break;
                end
            end
            if selectedIndex == -1
                return;
            end
            if p.keyInterpreter.controlDown &&...
                    numel(find(p.selected == selectedIndex)) > 0
                p.selected(p.selected == selectedIndex) = [];
            elseif p.keyInterpreter.controlDown
                p.selected(end + 1) = selectedIndex;
            else
                p.selected = selectedIndex;
            end
            p.displayImage();
        end
        function p = ensureProperSelection(p)
            p.selected(p.selected == 1) = [];
            if numel(find(p.selected == 2 | p.selected == 3)) >= 1 %If right or down selected
                if numel(find(p.selected == 4)) == 0 %If downRight not selected
                    p.selected = [p.selected,4];
                end
            end
            %If downRight selected and neither right or down are selected, then add
            %these two to the selected tiles
            if numel(find(p.selected == 4)) == 1 && numel(find(p.selected == 2 | p.selected == 3)) == 0
                p.selected = [p.selected,2];
                p.selected = [p.selected,3];
            end
        end

        function p = shiftSelectedImages(p,dimension, direction)
            p.ensureProperSelection();
            inc = p.getIncrement() * direction;
            for selection = p.selected
                switch selection
                    case 1
                        % currentUL is stationary
                    case 2
                        p.rightUL(dimension) = p.rightUL(dimension) + inc;
                    case 3
                        p.downUL(dimension) = p.downUL(dimension) + inc;
                    case 4
                        p.downRightUL(dimension) = p.downRightUL(dimension) + inc;
                end
            end
        end
        function inc = getIncrement(p)
            if p.keyInterpreter.controlDown
                inc = 1;
            else
                inc = 5;
            end
        end
        function setPanelInterpreter(p, panelInterpreter)
            p.panelInterpreter = panelInterpreter;
        end
        function displayImage(p)
            indexToLoc = containers.Map([1,2,3,4],{p.currentUL, p.rightUL,...
                   p.downUL, p.downRightUL});
            canvas = p.imageProvider.getCanvas(indexToLoc, p.order);
            set(p.imgAx, 'xlim',[0, size(canvas,1)]);
            set(p.imgAx, 'ylim',[0, size(canvas,2)]);
            imgH = imshow(canvas,'Parent',p.imgAx);
            p.drawCircles();
            p.panelInterpreter.rewire();
            display('Rewiring');
        end
        function drawCircles(p)
            indexToLoc = containers.Map([1,2,3,4],{p.currentUL, p.rightUL,...
                   p.downUL, p.downRightUL});
            for selection = p.selected
                upperLeft = indexToLoc(selection);
                row = upperLeft(1) + p.imageProvider.imageSize(1)/2;
                col = upperLeft(2) + p.imageProvider.imageSize(2)/2;
                cH = p.circle(col, row, ceil(p.imageProvider.imageSize(1)/100));
                set(cH, 'HitTest', 'off');
                display('drawing circle');
            end  
        end
        function h = circle(p, x,y,r)
            hold on
            th = 0:pi/50:2*pi;
            xunit = r * cos(th) + x;
            yunit = r * sin(th) + y;
            h = plot(xunit, yunit, 'Parent', p.imgAx);
            hold off
        end
    end
end

