function [ prob ] = imbalancePDF(T,m,p,I,varargin)
%%Generates the probability of obeserving a particular labling of maternal
%%and paternal probes out of a total mRNA T assuming the some allilic bias b
%for a given detection effiency or efficiencies
%   Parameters
%   T - total number of mRNA observed
%   m - # of mRNA that were labled as maternal
%   p - # of mRNA that were labled as paternal
%   I - imbalance toward maternal allele
%   d_m - detection effiency for maternal allele
%   d_p - [OPTIONAL] detection efficiency for paternal probe (assumed to be
%   equal to maternal detection efficiency if not input.

%Check if optional paternal detection efficiency was input
if nargin == 6
    d_m = varargin{1};
    d_p = varargin{2};
else
    d_m = varargin{1};
    d_p = d_m;
end

    n = 0:T;  %Vectorized summation vector over conditional values of T as # of detected maternal allele
    N = length(n);
    
    %Check for values that would invalidate the sum, ie make factorial negative
    invalidSum = or((n-m) < 0, (T-n-p) < 0);

    %Exclude those values from the sum
    n(invalidSum) = [];


    %Perform the vectorized sum in terms of binopdf
    sum_parts = binopdf(m,n,d_m).*binopdf(p,T-n,d_p).*binopdf(n,T,I);
    prob = sum(sum_parts); 

end
