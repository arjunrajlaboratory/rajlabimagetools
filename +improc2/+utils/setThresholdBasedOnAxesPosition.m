function setThresholdBasedOnAxesPosition(axH, processorDataHolder)
    currentPoint = get(axH, 'CurrentPoint');
    xLimits = get(axH, 'XLim');
    currentXPosition = max(min(currentPoint(1,1), xLimits(2)), xLimits(1));
    processorDataHolder.processorData.threshold = currentXPosition;
end

