function parentDirPath = locator()
        str = which('improc2.tests.volumedata.locator');
        endOfPath = length(str) - length('locator.m');
        parentDirPath = str(1:endOfPath);
end