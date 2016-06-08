function [ output_args ] = paramestimates_pdf(d_m, d_p, I_hat, T)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes hereT = total(1);

T = total(1);
d_m = d_bin;
I_hat = I;
num_Trials = 100000;



[o_m o_p] = experimentGenerator(d_m, d_m, I_hat, T, num_Trials);

I_dist = o_m./(o_m+o_p);

[n xout] = hist(I_dist, 10000);

prob = n./num_Trials;
cdf = cumsum(prob);

upperb = find(cdf > 0.975, 1, 'first');
lowerb = find(cdf < 0.025, 1, 'last');

[xout(lowerb) xout(upperb)]


 
% center = round(I_hat *  T);
% lowerb = round(0.1*T*I_hat/0.5);
% upperb = round(0.1*T*0.5/I_hat);
% 
% [o_m o_p] = ndgrid([center-lowerb:1:center+upperb], [T-center-lowerb:1:T-center+upperb]);
% 
% nullSpace = o_m + o_p > T;
% 
% o_m(nullSpace) = [];
% o_p(nullSpace) = [];
% 
% o_m = o_m';
% o_p = o_p';
% 
% T = repmat(T, size(o_m));
% d_m = repmat(d_m, size(o_m));
% I_hat = repmat(I_hat, size(o_m));
% 
% 
% prob = imbalancePDFvec([T o_m o_p], d_m, I_hat);
% I_s = transpose(o_m./(o_m+o_p));


