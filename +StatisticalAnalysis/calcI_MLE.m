function [ I_MLE ] = calcI_MLE(obs, d_m, d_p)
%For a given set of observations in the form [O_m O_p U], calculates I_MLE
%given the detection efficincies d_m and d_p based on the quadratic derivation.

if d_m ~= d_p

alpha = d_p - d_m;
beta = 1 - d_p;

b = obs(1)*alpha - obs(1)*beta - obs(2)*beta + obs(3)*alpha;
c = obs(1)*beta;
a = -alpha*(sum(obs));

I_MLE  = (- b - sqrt(b^2-4*a*c))./(2*a); %Solution to quadratic form derived as MLE estimate


else
    
I_MLE = max(obs(1)/(obs(1) + obs(2)),0); %Simple ratio when detection efficiencies are the same

end

end

