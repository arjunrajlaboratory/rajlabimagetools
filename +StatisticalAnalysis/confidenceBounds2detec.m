function [params] = confidenceBounds2detec(T, I_MLE, d_MLE_mat, d_MLE_pat, pval, numExps)
%Calculates the confidence interval for a desired degree of significance (pval)
%given a maximum likelihood estimate of the model parameters (I_MLE,
%d_MLE_mat, d_MLE_pat). This function assumes 1 known detection efficiency
%and imputes the other one without any sort of prior on the detection
%efficiency
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

switch d_MLE_mat == d_MLE_pat
    
case 1
    
MLEs(:,1) = obs_m/(obs_m + obs_p); %MLE estimates of I_MAT for the generated experiments
MLEs(:,2) = (obs_p+obs_m)/T;     %MLE estimates of d_p for the generated experiments    
    
otherwise
        
E_totM = min(round(obs_m./d_MLE_mat), T - obs_p);
E_totP = T - E_totM;

%MLEs(:,1) = arrayfun(@(x,y) calcI_MLE([x y T-x-y], d_MLE_mat, d_MLE_pat), obs_m, obs_p);

MLEs(:,1) = E_totM./T; %MLE estimates of I_MAT for the generated experiments
MLEs(:,2) = obs_p./(T - E_totM);     %MLE estimates of d_p for the generated experiments
% MLEs(:,3) = obs_m./E_totM;      %MLE estimates of d_m for the generated experiments


end
[hits val] = hist(MLEs, 1000);

pdfs = hits./numExps;
cdfs = cumsum(pdfs);

params = zeros(2,3);
params(:,1) = mean(MLEs)';

    for i = 1:2

        upperb_idx = find(cdfs(:,i) > 1-pval/2, 1, 'first');
        lowerb_idx = find(cdfs(:,i) < pval/2, 1, 'last');

        params(i,2:3) = [val(lowerb_idx) val(upperb_idx)];

    end