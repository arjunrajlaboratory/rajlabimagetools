function [ LL_vals LL_pdf LL_Obs singleCellConf I_obs] = analyzeSingleCellLikelihood(results, I_MLE, d_MLE_mat, d_MLE_pat, numExps)
%Performs analysis of single cell likelihood returning the likelihood
%distrubtion for the cells as well as the likelihood of the observed
%experiment. 
% Params
%   LL_vals - likelihood function 'x-values' for pdf
%   LL_pfs - corresponding liklihoods for the null hypothesis 'y-values'
%   LL_Obs - likelihood of the overall observed experiment
%   singleCellConf- [Nx3] matrix that contains the expected imbalance
%   (column 1), the top 95% confidence interval (column 2), and the bottom
%   95% confidence interval (column 3) for each cell calculated from the
%   individual PMFs
%   I_obs- the observed imbalances at each cell from the given experiment
%   (Nx1)
%

O_ms = results(:,1);
O_ps = results(:,2);
Us = results(:,3);
Tvec = O_ms + O_ps + Us;
N = length(Tvec);

I_obs = arrayfun(@(x,y,z) calcI_MLE([x,y,z], d_MLE_mat, d_MLE_pat), O_ms, O_ps, Us);  %MLE likelihoods for observation per cell

%Round away the demons (aka tolerance bounds)
 precision_exponent = fix(-log10(eps(I_obs))) - 1;
 I_obs = max(round(I_obs.*(10.^precision_exponent))./(10.^precision_exponent),0);

 
 %Calculate PMFs and CDFs for each cell
[I_vals I_PMFs] = arrayfun(@(x) imbalancePMFExplicit(x, I_MLE, d_MLE_mat, d_MLE_pat), Tvec, 'UniformOutput', false);
I_CDFs = cellfun(@cumsum, I_PMFs, 'UniformOutput', false); 

%Calculate 95% Confidence intervals for each cell
pval = 0.05;
    for i = 1:N

        upperb_idx = find(I_CDFs{i} >= 1 - pval/2, 1, 'first');
        lowerb_idx = find(I_CDFs{i} <= pval/2, 1, 'last');
            if isempty(lowerb_idx)
                lb = 0;
            else
                lb = I_vals{i}(lowerb_idx);
            end
            if isempty(upperb_idx)
                ub = 1;
            else
                ub = I_vals{i}(upperb_idx);
            end
        
        singleCellConf(i,:) = [I_MLE, lb, ub];

    end


%Compute the likelihood for the observed data
L_Obs_cell = zeros([N 1]);
for i = 1:N
    L_Obs_cell(i) = -log(I_PMFs{i}(I_vals{i} == I_obs(i)));
end

LL_Obs = sum(L_Obs_cell);


%Generate distribution of likelihoods for cells given population parameters
for i = 1:N
idx = discretesample(I_PMFs{i}, numExps);
Liklies(i,:) = I_PMFs{i}(idx);
end

LLs = sum(-log(Liklies));

[LL_counts LL_vals] = hist(LLs, 300);

LL_pdf = LL_counts./numExps;


end

