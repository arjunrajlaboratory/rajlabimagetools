function [ I_hat d_hat ] = imputeDetecI(obs, d_m)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

T = sum(obs);

a1 = - obs(3) * d_m;
a2 =  obs(2) - obs(2)*d_m - d_m*obs(3);

b1 = obs(2)*d_m - obs(2) - obs(3);
b2 = obs(3);

c(1) = -a1*T;
c(2) = -a2*T + obs(3)*a1 + obs(1)*a1 - obs(1)*b1 - obs(2)*b1;
c(3) = obs(3)*a2 + obs(1)*a2 - obs(1)*b2 - obs(2)*b2 + obs(1)*b1;
c(4) = obs(1)*b2;


I_hat = roots(c);

d_hat = obs(2).*(1-d_m.*I_hat)./((obs(2) + obs(3) - (obs(2)+obs(3)).*I_hat));

end

