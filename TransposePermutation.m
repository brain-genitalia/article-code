function w = TransposePermutation(v)
% v is a vector of permutation that represents a permutation matrix P
% The functions returns w, which is a vector representing the permutation
% matrix P'.
L = length(v);
w = zeros(L, 1);
w(v) = 1:1:L;

end
