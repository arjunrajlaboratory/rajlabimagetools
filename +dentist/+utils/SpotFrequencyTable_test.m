dentist.tests.cleanupForTests;

table1 = [1.3567, 1.2345, 1.4367, 1.2345];

spotTable = dentist.utils.SpotFrequencyTable(table1);

assert(all(spotTable.values == [1.23; 1.36; 1.44]))
assert(all(spotTable.frequencies == [2; 1; 1]))

spotTable = spotTable.addSpotIntensityValues([1.3649, 1.3651]);

assert(all(spotTable.values == [1.23; 1.36; 1.37; 1.44]));
assert(all(spotTable.frequencies == [2; 2; 1; 1]));

%% add tables test.

dentist.tests.cleanupForTests;

table1 = [1.3567, 1.2345, 1.4367, 1.2345];
spotTable1 = dentist.utils.SpotFrequencyTable(table1);

table2 = [1.3649, 1.3651];
spotTable2 = dentist.utils.SpotFrequencyTable(table2);

spotTable = add(spotTable1, spotTable2);

assert(all(spotTable.values == [1.23; 1.36; 1.37; 1.44]));
assert(all(spotTable.frequencies == [2; 2; 1; 1]));

