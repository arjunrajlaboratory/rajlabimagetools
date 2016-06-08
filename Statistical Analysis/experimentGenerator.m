function [ obs ] = experimentGenerator(d_m, d_p, I_m_hat, T, N )
%Simulates in-silico experiments to generate data from the best estimate
%model. Returns results of the experiment in the form of observed maternal
%and observed paternal spots. Will not produce any uninformtaive examples.
%(Om = 0 and O_p = 0).
%   Parameters
%   T - total number of mRNA observed
%   I_hat - MLE estimate of imbalance toward maternal allele
%   d_m - detection effiency for maternal allele
%   d_p - detection efficiency for paternal probe

obs_M = 0;
obs_P = 0;

%multinomial parameters
alpha = d_m*I_m_hat;
beta = d_p * (1-I_m_hat);
gamma = 1 - alpha - beta;

p = [alpha beta gamma]; %probability vector

obs = mnrnd(T, p, N);


%Randomly resample to remove the (0,0) entries
while any(and(obs(1,:) == 0, obs(2,:) == 0))
    reroll_idx = and(obs(1,:) == 0, obs(2,:) == 0);
    numb_to_reroll = sum(reroll_idx);
    obs(reroll_idx, :) = mnrnd(T, p, numb_to_reroll)
end


end

