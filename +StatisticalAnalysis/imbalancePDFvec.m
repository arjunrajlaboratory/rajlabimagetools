function [ pdf ] = imbalancePDFvec(observations, I, d_mat, d_pat)
%Vectorized implementation of the imbalancePDF function. Returns a set of
%probabilities the probabilty observing experiments with a given input
%   Parameters
%   observations- an N x 3 matrix where each row is an independent
%       experiment. The first column is the total mRNA detected, the second
%       column is the maternal mRNA detected, and the third column is the
%       paternal mRNA detected.  
%   I- imbalance toward maternal allele (ranges 0 - 1)
%   d_mat- detection efficiency of the maternal allele 
%   d_pat- detection efficiency of the paternal allele. Assumned
%       to be equal to d_mat unless otherwise specified.


%Admittedly very clunky way of doing a singleton expansion =(
    vars{1} = observations;
    vars{2} = I;
    vars{3} = d_mat;
    vars{4} = d_pat;
    
    s(1,:) = size(observations);
    s(2,:) = size(I);
    s(3,:) = size(d_mat);
    s(4,:) = size(d_pat);
    s = s(:,1);
    dim = max(s);
    
    for i = 1:4
        if s(i) == 1
            vars{i} = repmat(vars{i}, [dim 1]);
        end
    end
    
    
   %Use arrayfun to vectorize the imbalancePDF function

    observations = vars{1};
    t = observations(:,1);
    m = observations(:,2);
    p = observations(:,3);
    
    pdf = arrayfun(@(x,y,z,w,v,u) imbalancePDF(x,y,z,w,v,u), t, m, p, vars{2}, vars{3}, vars{4});

end

