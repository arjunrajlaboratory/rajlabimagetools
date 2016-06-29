function [ prob ] = snpDetectionProb(T,m,p,d,b)
%%Generates the probability of obeserving a particular labling of maternal
%%and paternal probes out of a total mRNA T assuming the some allilic bias b
%for a given detection effiency d
%   Parameters
%   T - total number of mRNA observed
%   m - # of mRNA that were labled as maternal
%   p - # of mRNA that were labled as paternal
%   d - detection effiency
%   b - bias

    n = 0:T;  %Vectorized summation term
    N = length(n);

    %Check for values that would invalidate the sum, ie make factorial negative
    invalidSum = or((n-m) < 0, (T-n-p) < 0);

    %Exclude those values from the sum
    n(invalidSum) = [];

    %Perform the vectorized sum
    sum_parts = factorial(T)./(factorial(m).*factorial(p).*factorial(n-m).*factorial(T-n-p)) .* d.^(m+p).*(1-d).^(T-m-p).*(b).^n.*(1-b).^(T-n);
    prob = sum(sum_parts);

end

