function [params] = confidenceBounds(T, I_MLE, d_MLE_mat, d_MLE_pat, pval, numExps)
%Calculates the confidence interval for a desired degree of significance (pval)
%given a maximum likelihood estimate of the model parameters (I_MLE,
%d_MLE_mat, d_MLE_pat)
%   Parameters
%   T- total RNA observed in a given experiment
%   I_MLE- imbalance param estimate maternal allele (ranges 0 - 1)
%   d_mat- detection efficiency param estimate of the maternal allele 
%   d_pat- detection efficiency param estimate of the paternal allele
%   Output- params (2x3 matrix)
%           [mean(I)   I_lowerb  I_upperb]
%           [mean(d)   d_lowerb  d_upperb]
%



[obs_m obs_p] = experimentGenerator(d_MLE_mat, d_MLE_pat, I_MLE, T, numExps);

MLEs(:,1) = obs_m./(obs_m+obs_p); %MLE estimates of I for the generated experiments
MLEs(:,2) = (obs_m + obs_p)/T;    %MLE estimates of d for the generated experiments  

[hits val] = hist(MLEs, 1000);

pdfs = hits./numExps;
cdfs = cumsum(pdfs);

params = zeros(2,3);
params(:,1) = mean(MLEs)';


    for i = 1:2

        upperb_idx = find(cdfs(:,i) >= 1-pval/2, 1, 'first');
        lowerb_idx = find(cdfs(:,i) <= pval/2, 1, 'last');
        
        if isempty(upperb_idx)
            upperb_idx = length(val);
        end
        
        if isempty(lowerb_idx)
            lowerb_idx = 1;
        end

        params(i,2:3) = [val(lowerb_idx) val(upperb_idx)];

    end