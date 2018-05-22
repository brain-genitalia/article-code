function [ epsilon, L ] = estimate_epsilon ( dists )
% Estimate epsilon 
epsilon = mean( dists(:))^3;
L = [];
return;
