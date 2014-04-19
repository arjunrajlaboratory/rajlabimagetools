function [ mexcerr ] = badArgumentsError( customstring )
%UNTITLED18 Summary of this function goes here
%   Detailed explanation goes here
if nargin < 1
    customstring = 'Bad Arguments to function/method';
end

mexcerr = MException('improc2:BadArguments', customstring);

end

