function [ output_args ] = I_hat_pdf(d_m, d_p, I_hat, T, N)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


[obs_m obs_p] = experimentGenerator(d_m, d_p, I_hat, T, N);


Gen_Is = obs_m./(obs_m + obs_p);
Gen_ds = (obs_m + obs_p)./T;



end

