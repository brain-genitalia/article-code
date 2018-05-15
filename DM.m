function [ map , eigenValues , eigenVectors] = DM(dists,epsilon,dimension)

if (nargin == 2)
    dimension = size(dists,1)-1;
end


W = exp(-dists.^2/epsilon);
D = diag(1./sqrt(sum(W)));
K = D*W*D;

% [U,S,V] = svd(K);

[eigenVectors , eigenValues] = sort_eig(K);
eigenVectors = real(eigenVectors);
eigenValues = real(eigenValues);
map = D*eigenVectors*eigenValues;

map = map(:,2:dimension+1);
% map = [] ;