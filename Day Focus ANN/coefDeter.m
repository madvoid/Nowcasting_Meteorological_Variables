function [ rSquared ] = coefDeter(y, f)
% Calculates the coefficient of determination (R^2) for two vectors x and y
%
% INPUT: Two vectors, f and y. Must be same length. f is the *prediction* or *model*
% to y
%
% OUTPUT: R^2 value for the two vectors
%
% NOTES: All sums and means ignore NaNs
%        See http://en.wikipedia.org/wiki/Coefficient_of_determination
%

if nargin ~= 2
    error('Please enter exactly two input vectors');
end

if length(f) ~= length(y)
    error('Two vectors must be same length')
end

yBar = nanmean(y);

SStot = nansum( (y - yBar).^2 );
SSres = nansum( (y - f).^2 );

rSquared = 1 - SSres/SStot;


end

