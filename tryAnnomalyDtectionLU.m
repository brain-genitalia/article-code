function score = tryAnnomalyDtectionLU( baseMat , otherMat )
% This function run anomaly detection using randomized LU decomposition

%% Parameters

S = svd(baseMat);
eigenValuesNormalized = diag( S ) / S( 1 , 1 );
%             figure; plot( eigenValuesNormalized );
k = sum( eigenValuesNormalized > 0.001 );

%k=5; % Dictinary size  360 data
l=min( k+5 , size( baseMat , 1 ) ); % Number of random projections (should be slightly larger than k).
q=2; % Number of power iterations
gpu = false;
normalize = false;
binning = true;
%% Read Data
Training = baseMat';
Testing = otherMat';

if gpu
    Training = gpuArray(Training);
    Testing = gpuArray(Testing);
    pinvMode = 'gpu';
else
    pinvMode = 'gauss';
end

%% Normalization (binning)
% s=svd(Training);
% figure;
% plot(s);
% title('Singular Values, before binning');
if  binning
    [training_norm_points, training_norm_epsilons, training_norm_sums] = Training_BinFeatures(Training', min(size(Training)), 1000);
    testing_norm_points = Testing_BinFeatures(Testing', min(size(Testing)), training_norm_sums, 1000*ones(min(size(Testing)),1), training_norm_epsilons);
    Training = training_norm_points';
    Testing = testing_norm_points';
    
%     s=svd(Training);
%     figure;
%     plot(s);
%     title('Singular Values, after binning');
end
%% Build LU Dictionary
h=tic;
[L,U,P,Q]=randomizedLU(Training,k,l,q,'econ',gpu);
v = TransposePermutation(P);
Dictionary = L(v,:);
DictionaryPinv = Fastpinv(Dictionary, pinvMode);
%Detector = Dictionary*Fastpinv(Dictionary, pinvMode);
fprintf('LU Approximation error=%g \n',norm(Training(P,Q)-L*U)/norm(Training));
%% Look for Anomalies in the Testing data set
if normalize
    score = sqrt(sum((Dictionary*(DictionaryPinv*Testing)-Testing).^2));
    NormFactor = sqrt(sum(Testing.^2));
    NormFactor(NormFactor==0)=1;
    score = score./NormFactor;
else
    score = sqrt(sum((Dictionary*(DictionaryPinv*Testing)-Testing).^2));
end


end

