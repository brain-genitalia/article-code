function [ L, U, P1, P2, invL ] = randomizedLU( A,l,k,q,mode, gpu, density)
%   A randomized version of LU decomposition.
%   Parameters:
%   A is the matrix to be factorized.
%   k is the required rank of the L*U approximation. i.e. rank(L*U).
%   l is the extra elements to pick to increase the success probability
%   q is the number of power iterations to perform (small integer) for
%   improved accuracy on the account of speed. Default is q=0.
%   mode - full or 'econ'. Default is economy.
%   gpu - boolean for indicating whether to run on GPU.
%   P1 and P2 are the permutation matrices, represented as vectors, the
%   error is A(P1,P2)-L*U
if nargin==3
    q=0;
    mode = 'econ';
    gpu = false;
    density=1;
elseif nargin==4
    mode = 'econ';
    gpu = false;
    density=1;
elseif nargin==5
    mode = 'econ';
    gpu = false;
    density=1;
elseif nargin==6
    density=1;
end

pinvmode = 'gauss';
if gpu
    pinvmode = 'gpu';
end

[n, m]=size(A);
l = min([l m n]);
if gpu
    Omega = gpuArray.randn(m,l);
    if density<1
        Omega = Omega.*(gpuArray.*rand(m,l)<density)/density;
    end
else
    Omega = randn(m,l);
    if density<1
        Omega = Omega.*(rand(m,l)<density)/density;
    end
        
end


Y= A*Omega;
if q>0
    for ii = 1:q
        Y=A*(A'*Y);
    end
end

[Ly, ~, Py] = lu(Y,'vector');
if l>k
    Ly = Ly(:,1:k);
end
%I = eye(size(Ly,1));
%B=permright(pinv(Ly),Py)*A;
%B = (Ly\Py)*A;
%B = permright(Fastpinv(Ly,'regular'),Py)*A;
invL = Fastpinv(Ly,pinvmode);
%B = B*Py*A;
B = invL*A(Py,:);
[Lb, Ub, Pb] = LU_Col(B,'regular');
%[Lb, Ub, Pb] = lu(B);

L = Ly*Lb;
U = Ub;
P1=Py;
P2=Pb;
if strcmp(mode,'full')
    L = [L zeros(n,n-k)];
    U = [U; zeros(n-k,m)];
end

end

function B = permright(A,P)
% Form, efficiently, A*P where P is a permutation matrix
% Usage B = permright(A,P);
% Input:  A  - an m by n matrix
%         P  - an n by n permutation matrix 
% Output: B = A * P
if ( length(P) > 0 )
  [pv,pvt]=find(P==1);
  B=A(:,pv);
else
  B = A ;
end

end
%--------------------------------------------

function B = permleft(A,P)
% Form, efficiently, P*A where P is a permutation matrix
% Usage B = permleft(A,P);
% Input:  A  - an m by n matrix
%         P  - an m by m permutation matrix 
% Output: B = P * A
if (length(P) > 0 )
  [pv,pvt]=find(P'==1);
  B=A(pv,:);
else
  B = A;
end

end