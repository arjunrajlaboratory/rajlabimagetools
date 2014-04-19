function output = runWhileSuppressingNeedsUpdateWarning(zeroInputOneOutputFUNC)
    warnstate = warning('off', 'improc2:GetFromNeedingRunOrUpdate');
    try
        output = zeroInputOneOutputFUNC();
    catch err
        warning(warnstate)
        rethrow(err)
    end
    warning(warnstate)
end

