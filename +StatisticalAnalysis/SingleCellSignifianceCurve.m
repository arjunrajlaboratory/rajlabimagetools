%Siginifance plot for T = 20

T = 20;
[a b] = ndgrid(0:T);

nullSpace = a + b > T;

a(nullSpace) = [];
b(nullSpace) = [];

obs = [repmat(T, size(a')) a' b'];

pdf = snpDetectionPdf(obs, 0.6);

[prob idx] = sort(pdf, 'descend');

significant = cumsum(prob) > 0.95;

likelihood = [a' b' pdf];
likelihood = likelihood(idx,:);

C = repmat([1 0 0], size(prob));
C(significant,:) = repmat([0 0 1], [sum(significant) 1]);

scatter3(likelihood(:,1), likelihood(:,2), likelihood(:,3),20, C, 'filled')
title(['Manifold of Signifiance p  > 0.05 at for a total mRNA count of ' num2str(T)])
xlabel('Observed count of maternal allele')
ylabel('Observed count of paternal allele')
zlabel('Likelihood')