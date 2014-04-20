function parentDirPath = locator()
        str = which('dentist.tests.data.locator');
        endOfPath = length(str) - length('locator.m');
        parentDirPath = str(1:endOfPath);
end

