function [filteredPoints, keptIndices] = filterPointsByViewport(Points, viewport)

keptIndices = viewport.ulCornerXPosition - 0.5 < Points.xPositions & ...
    viewport.ulCornerXPosition + viewport.width - 1 + 0.5 > Points.xPositions & ...
    viewport.ulCornerYPosition - 0.5 < Points.yPositions & ...
    viewport.ulCornerYPosition + viewport.height - 1 + 0.5 > Points.yPositions;

keptIndices = find(keptIndices);
filteredPoints = Points.subsetByIndices(keptIndices);
end

