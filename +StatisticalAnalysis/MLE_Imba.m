function [ val ] = MLE_Imba(T,m,p,d,b)
%MLE for Imbalance

    n = 0:T;  %Vectorized summation term
    N = length(n);

    %Check for values that would invalidate the sum, ie make factorial negative
    invalidSum = or((n-m) < 0, (T-n-p) < 0);

    %Exclude those values from the sum
    n(invalidSum) = [];

    %Perform the vectorized sum
    sum_parts = (b).^n.*(1-b).^(T-n)./(factorial(n-m).*factorial(T-n-p)) .*(n./b- (T-n)./(1-b));
    val= sum(sum_parts);

end

