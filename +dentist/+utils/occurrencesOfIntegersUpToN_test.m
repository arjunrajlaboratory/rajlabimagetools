a = 1:6;
b = [4, 1, 2, 4, 4, 1];

y = dentist.utils.occurrencesOfIntegersUpToN(b, max(a));
assert(all(y == [2, 1, 0, 3, 0, 0]'))

z = dentist.utils.occurrencesOfIntegersUpToN([], max(a));
assert(all(z == zeros(max(a),1)))
