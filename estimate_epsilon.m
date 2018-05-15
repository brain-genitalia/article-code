function [ epsilon, L ] = estimate_epsilon ( dists )
% Estimate epsilon using Singer's method.
% e -> -Inf => L -> N
% e -> +Inf => L -> N^2
% epsilon is chosen from the middle
% 2010 Tuomo Sipola (tuomo.sipola@jyu.fi)
%   epsilon = estimate_epsilon ( x )
% Parameters:
%   x       Input data which should be in format time x parameters. 
%   samples How many samples to use for this epsilon estimation, default 200.
% Returns:
%   epsilon The estimated value for epsilon for later use in diffusion map.
%   L       The sum of kernel as a function of epsilon. Optional.

% Number of measurements
% dists = dists / max( dists(:));

epsilon = mean( dists(:))^3;
L = [];
return;

n = size(dists,1);

ep = [ 0.001:0.001:0.01 0.02:0.01:0.1 0.2:0.1:1 2:1:10 20:10:100 200:100:1000 2000:1000:10000 20000:10000:100000 200000:100000:1000000 ];
L = zeros(1,length(ep));

for ks=1:length(ep)
	% Calculate the weight matrix, or affinity between the measured points.
	% Use the kernel e^-||x_i - x_j||^2/e
	W = exp( -dists.^2 / ep(ks) );

	L(ks) = sum(sum(W));
end

%[v, idx] = max(diff(log(L)));
%epsilon = ep(idx);

threshold = exp( log(n) + ( (log(n^2)-log(n))./2 ) );
idx = find(threshold < L, 1);
epsilon = ep(idx);

figure
loglog(ep, L)
hold on
grid on
loglog([epsilon epsilon], [n n.^2], 'r')
title('The weight matrix sum as a function of epsilon')
xlabel('\epsilon')
ylabel('L')

