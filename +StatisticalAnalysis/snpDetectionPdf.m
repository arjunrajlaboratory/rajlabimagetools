function [ pdf ] = imbalancePDFvec(observations, d, b)
%snpDetectionPdf Returns a set of probability vectors for with an input as
%a matrix of experiments with total mRNA in column 1, mat in column2, pat
%in column 3. It also takes a detection effiency parameter d.

    t = observations(:,1);
    m = observations(:,2);
    p = observations(:,3);
    
    for i = 1:length(results)
        
    end
    
    pdf = arrayfun(@(x,y,z,w,v) snpDetectionprob(x,y,z,w,v), t, m, p, d, b);
%     pdf = bsxfun(@rdivide, pdf, sum(pdf));
%     pdf(isnan(pdf)) = 0;
end

