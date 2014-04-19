function y = gaussian2dfunc(c,X)

%input X is two columns - [x y]
%c(1) is the amplitude amp
%c(2) is the offset
%c(3) is the inverse of the standard deviation
%c(4) is the x mean
%c(5) is the y mean

%Fixed factor of 2 here

y=c(2)+c(1)*exp(-c(3)^2*((X(:,1)-c(4)).^2+(X(:,2)-c(5)).^2)/2);


end

%imwrite(reshape(gaussian2dfunc([1 0 0.1 500 500],[theXs(:),theYs(:)]),[1024,1024]),'tempmock.tiff');
