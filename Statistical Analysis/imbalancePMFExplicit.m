function [ I_val I_pmf ] = imbalancePMFExplicit(Total, I_MLE, d_MLE_mat, d_MLE_pat)
%Calculates the analytical PMF for the imbalance parameters given an obeserved RNA total. 
% Returns a matrix whose first column is the value of I and the second
% column is the associated probability

[space_m space_p] = ndgrid(0:Total, 0:Total);

space_m = space_m(:);
space_p = space_p(:);

null = (space_m + space_p) > Total;

space_m(null) = [];
space_p(null) = [];

null2 = and(space_m == 0, space_p == 0); %Do not allow non-informative spaces where both detected probes are zero

space_m(null2) = [];
space_p(null2) = [];

space_u = Total - space_m - space_p;

X = [space_m, space_p, space_u];
P = [I_MLE*d_MLE_mat, (1-I_MLE)*d_MLE_pat, 1+I_MLE*d_MLE_pat-I_MLE*d_MLE_mat-d_MLE_pat];

%exps = [repmat(Tvec,size(space_m)), space_m, space_p];
%Ls = imbalancePDFvec(exps, I_MLE, d_MLE_mat, d_MLE_pat);

L = mnpdf(X,P); %GENERATE EXPERIMENTS

%Is = max(space_m./(space_m + space_p), 0);
Is = arrayfun(@(x,y,z) calcI_MLE([x,y,z], d_MLE_mat, d_MLE_pat), space_m, space_p, space_u);  

%Round away the demons (aka tolerance bounds)
 precision_exponent = fix(-log10(eps(Is))) - 1;
 Is = max(round(Is.*(10.^precision_exponent))./(10.^precision_exponent),0);

[Is_sorted idx] = sort(Is);
L_sorted = L(idx);

[I_val index_sorted_last index_pmf] = unique(Is_sorted, 'last');
[I_val index_sorted_first index_pmf] = unique(Is_sorted, 'first');

% needsMarginalization = (index_sorted_last ~= index_sorted_first);
% sumRanges = [index_sorted_first(needsMarginalization) index_sorted_last(needsMarginalization)];

I_pmf = arrayfun(@(idx_f, idx_l) sum(L_sorted(idx_f:idx_l)), index_sorted_first, index_sorted_last);

%I = [I_val I_pmf];

% length(I_pmf)
% length(L)

end

