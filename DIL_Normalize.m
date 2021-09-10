%% Normalization function
%{
This normalization function is used for normalized one known matrix.

NOTE: in terms of normalization, it should contain mean-centering, or scaling, 
or their combination. In the future, I plan to add more input parameters, such
as Options and Switches.

Author: ShuKun Zhao.
Data: April 2, 2010
%}
function [nlX] = DIL_Normalize (X)
%{
INPUT
    X: the original matrix, X. X consists of a group of column vectors.
OUTPUT
    nlX: Normalized X.
%}

[rX, cX] = size(X);

% Method 1: Z-Score
meanX = mean(X, 1);
nlX = [];
stdXvector = std(X);
stdX = [];

% construct Standard Deviation matrix and Mean matrix
for k = 1 : rX
    stdX = [stdX; stdXvector];
    nlX = [nlX; meanX];
end

nlX = (X - nlX);

nlX = nlX ./ stdX;

% Method 2: Simple mean-centering
%{
nlX = mean(X, 1);
nlX = X - nlX;
%}

