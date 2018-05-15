function pinvA = Fastpinv(A, mode)
if nargin<2
    mode = 'regular';
end

if strcmp(mode, 'regular')
    [u,s,v]=svd(A,'econ');
    pinvA = v*pinv(s)*u';
elseif strcmp(mode, 'sparse')
    pinvA = inv(A'*A)*A';
elseif strcmp(mode, 'multpinv')
    pinvA = pinv(A'*A)*A';
elseif strcmp(mode,'gpu')
    pinvA = ((A'*A)\(gpuArray(single(eye(size(A,2))))))*A';
elseif strcmp(mode, 'gauss')
    pinvA = ((A'*A)\(eye(size(A,2))))*A';

    
end

end

    
    
    

    