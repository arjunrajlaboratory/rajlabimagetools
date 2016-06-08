function [params] = confidenceBoundsdetec(T, I_MLE, d_MLE_mat, d_MLE_pat, pval, numExps)
%Calculates the confidence interval for a desired degree of significance (pval)
%given a maximum likelihood estimate of the model parameters (I_MLE,
%d_MLE_mat, d_MLE_pat). This function assumes two "known" detection
%efficiencies
%   Parameters
%   T- total RNA observed in a given experiment
%   I_MLE- imbalance param estimate maternal allele (ranges 0 - 1)
%   d_mat- detection efficiency param estimate of the maternal allele 
%   d_pat- detection efficiency param estimate of the paternal allele
%   Output- params (2x3 matrix)
%           [mean(I)   I_lowerb  I_upperb]
%           [mean(d)   d_lowerb  d_upperb]
%


obs = experimentGenerator(d_MLE_mat, d_MLE_pat, I_MLE, T, numExps);

MLEs = arrayfun(@(x,y) calcI_MLE([x, y, T - x- y], d_MLE_mat, d_MLE_pat), obs(:,1), obs(:,2)); %MLE estimates of I_MAT for the generated experiments

params = zeros(1,3);
params(:,1) = mean(MLEs)';
params(:,2) = prctile(MLEs, 100*pval/2);    %lower bound
params(:,3) = prctile(MLEs, (1 - pval/2)*100); %upper bound


end
% [hits val] = hist(MLEs, 1000);
% 
% pdfs = hits./numExps;
% cdfs = cumsum(pdfs);
% 
% params = zeros(1,3);
% params(:,1) = mean(MLEs)';
% 
%     for i = 1
% 
%         upperb_idx = find(cdfs > 1-pval/2, 1, 'first');
%         lowerb_idx = find(cdfs < pval/2, 1, 'last');
% 
%         params(i,2:3) = [val(lowerb_idx) val(upperb_idx)];
% 
%     end