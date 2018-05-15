function [map, pi, s, FMdict, dict , FullMap, disortion] = ICPQR_DM(data,epsilon,mu)

% global distance
%output: map -  nxs reduced map, n-number of data points, s - dictionary size
%        pi, s - for the Extend().
%        FMdict - nxs full map of the s elements of the dictionary into s
%        dimensional space.
%        dict - indices of the dictionary.
dists = pdist2(data,data );
K = exp(-dists.^2/epsilon);
pi = sum(K);
s = sum(pi); %L1 normalization
probs = bsxfun(@rdivide,K,pi');
FullMap = sqrt(s)*diag(pi.^(-1/2))*probs';

[map, dict, disortion] = ICPQR(FullMap,mu);
map = map';

FMdict = FullMap(:,dict);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end

function [R, Dictionary, act_max_distort] = ICPQR(M,mu)
% [R, P, act_max_distort] = ICPQR(M,mu)
% Input: An rxc matrix M and a nonnegative accuracy parameter mu. 
% Output: A pxc matrix R, for which max(max(abs(pdist2(M',M')-pdist2(R',R'))) <= 2*mu. 
%         A dictionary, consists of the indices of milestones data points,
%         and a nonnegative scalar act_max_distort =
%         max(max(abs(pdist2(M',M')-pdist2(R',R'))) - the actual maximal
%         distortion.
%
% The algorithm implement an incomplete pivoted Q-less QR for the matrix M,
% and stops when the all c data points in R^r (M's columns) are approximated 
% up to accuracy mu by the columns of R in R^p.  
% 
% M is A in article
D = sum(M.^2); % z in article
N = size(M,2);
NonDict = 1:N;
[cq, q] = max(sqrt(D));
Dictionary = zeros(1,N);
Dictionary(1) = q;
S = zeros(1,N); % y in article
NonDict(q) = [];
R = zeros(N);
R(1,:) = M(:,q)'*M/cq;
for ss = 2:N
    S(NonDict) = S(NonDict)+R(ss-1,NonDict).^2;
    C = sqrt(D(NonDict)-S(NonDict));
    [cq, qq] = max(C);
    q = NonDict(qq);
    Dictionary(ss) = q;
    NonDict(qq) = [];
    if (cq <= max(mu, 10e-15))
        ss = ss-1;
        break;
    end
    NR = zeros(1,N);
    NR(q) = cq;
    NR(NonDict) = (cq^(-1))*(M(:,q)'*M(:,NonDict)-R(1:ss-1,q)'*R(1:ss-1,NonDict));
    R(ss,:) = NR;
    %R = [R;NR];
end
Dictionary(ss+1:end) = [];
R(ss+1:end,:) = [];
act_max_distort = cq;
% 
% delta = mu-act_max_distort;
% orth_tr = eye(ss);
% 
% if (delta>0)
%     [UR, SR,VR] = svd(R,'econ');
%     k = find(diag(SR)>delta,1,'last');
%     if (isempty(k))
%         k=1;
%     end
%     if (k<ss)
%         R = SR(1:k,1:k)*VR(:,1:k)';
%         orth_tr = UR;
%     end
% end
%     
end
