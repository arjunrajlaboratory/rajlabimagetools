function [I_lower I_upper] = confidenceBounds(T, I_MLE, d_MLE_mat, d_MLE_pat, pval, numExps)
%Calculates the confidence interval for a desired degree of significance (pval)
%given a maximum likelihood estimate of the model parameters (I_MLE,
%d_MLE_mat, d_MLE_pat)
%   Parameters
%   T- total RNA observed in a given experiment
%   I_MLE- imbalance param estimate maternal allele (ranges 0 - 1)
%   d_mat- detection efficiency param estimate of the maternal allele 
%   d_pat- detection efficiency param estimate of the paternal allele


[obs_m obs_p] = experimentGenerator(d_MLE, d_MLE, I_MLE, totals(1), numExps);

MLEs(:,1) = obs_m./(obs_m+obs_p); %MLE estimates of I for the generated experiments
MLEs(:,2) = (obs_m + obs_p)/T;    %MLE estimates of d for the generated experiments  



for i = 1:2
[n_I xout_I] = hist(I_mle_s, 100);

pdf_I = n_I./numExps;
cdf_I = cumsum(pdf_I);

upperb_idx_I = find(cdf_I > 1-p/2, 1, 'first');
lowerb_idx_I = find(cdf_I < p/2, 1, 'last');

I_lower = xout_I(lowerb_idx_I);
I_upper = xout_I(upperb_idx_I);

end

[mean(I_mle_s) I_lower I_upper]


%Range of I's to test. **NOTE: you may need to expand this range in certain
%extreme cases as it is assumed that the probability that I falls outside
%of this range is zero. You can also change the step;
range = 0.1;        %radius to explore about the MLE estimate of I
step = 0.0001;      %radius to explore 

I_hat = I_MLE-range:step:I_MLE+range;
I_hat = I_hat';

likelihoods = imbalancePDFvec(obs, I_hat, d_MLE_mat, d_MLE_pat);

I_hat_pdf = likelihoods./sum(likelihoods);
I_hat_cdf = cumsum(I_hat_pdf);

upper = 1 - pval/2;
lower = pval/2;

upperb_idx = find(I_hat_cdf > upper, 1, 'first');
lowerb_idx = find(I_hat_cdf < lower, 1, 'last');

I_upper = I_hat(upperb_idx);
I_lower = I_hat(lowerb_idx);

end

