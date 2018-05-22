global reduceMethods
global Methods_unsupervised
global GROUP_SIZES

MU = 10.^(-8 : 2 : -2);
%% initializa variable
% 1 - unsuperVised
% 2 - annomaly detection
such = [ 1 2];
ADMaleModelResult = [] ;
ADFemaleModelResult = [];
unsupervisedResult2_10 = [];
FemaleTotError = [] ;
MaleTotError = [] ;
allClusterComposition = [];
allClust_2_10 = {};

reduceMethods = {'none' , 'pca' , 'dm' , 'PDME' , 'ICPQR' , 'ICPQR_data' };
Methods_unsupervised = {'kmeans' , 'linkage' };

if ~exist('setName' , 'var' )
    setName = 'GSP_VBM';
end
fprintf('set name is %s\n' , setName)
%% load data
load ( fullfile( setName, 'allDataGroupsOriginal.mat' ) );

load dims;
if GROUP_SIZES
    allGroups = double( allFullSize < median( allFullSize) )  + 1;
end
originalData = allData;

%% main loop
for i = 1 : length( reduceMethods )
    reduce = reduceMethods{ i };
    normData = zscore( allData );
    if strcmp( reduce , 'pca' ) || strcmp( reduce , 'dm' ) || strcmp( reduce , 'none' )
        mu = 0;
        eps = 0;
        if strcmp( reduce , 'dm' )
            eps = estimate_epsilon( ...
                pdist2( normData , normData ) );
        end
    else
        if strcmp( reduce , 'ICPQR_data')
            eps = 0;
        else
            eps = estimate_epsilon( ...
                pdist2( normData , normData ) );
        end
        mu = MU;
    end
    for curMu = mu
        fprintf('autoEpsilon method is %s , epsilon is %.2f , mu is %.2f\n' , reduce , eps , curMu );
        name = sprintf('data/method is %s , epsilon is %s , mu is %s .mat' , reduce , num2str(eps) , num2str(curMu));
        name = fullfile( setName , name );
        if exist(name , 'file' )
            a = load( name );
            reducingData = a.reducingData;
        else
            reducingData = getReducingData( normData , reduce , eps , curMu );
            save(name , 'reducingData' );
        end
        if strcmp( reduce , 'PDME') || strcmp( reduce , 'ICPQR')
            reducingData = reducingData(: , 2 : end );
        end
        if isempty( reducingData )
            continue
        end
        % determine the number of relevant dimensions
        [U,S,V] = svd(reducingData);
        if any( size(S) == 1 )
            continue
        end
        eigenValuesNormalized = diag( S ) / S( 1 , 1 );
        maxDim = findMaxDim(eigenValuesNormalized );
        if strcmp( reduce , 'none')
            maxDim = size(reducingData , 2 );
        end
        maxDim = min( [ maxDim , size(reducingData , 2 ) , ...
            size( originalData, 2 ) ]);
        dim = maxDim;
        if dim < 0
            break;
        end
        curData = reducingData( : , 1 : dim );
        for p = such
            switch p
                case 1 % clusterin
                    [ allClust , clusterComposition] = tryMyCluster( curData , allGroups , 2 : 10);
                    allClusterComposition = [allClusterComposition ; clusterComposition ];
                    allClust_2_10{end+1} = allClust;
                    unsupervisedResult2_10 = [ unsupervisedResult2_10 ; i , dim , eps , curMu ];
               case 2 % snomaly detection
                    [ res , totError ] = tryAnnomalyDtection( curData , allGroups , 1);
                    MaleTotError = [MaleTotError , totError] ;
                    curRes = [ repmat( [ i , dim , eps , curMu ]  , [size( res , 1 ) , 1 ] ) ...
                        res ];
                    ADMaleModelResult = [ ADMaleModelResult ; curRes];

                    [ res , resLU , totError ] = tryAnnomalyDtection( curData , allGroups , 2);
                    FemaleTotError = [FemaleTotError , totError] ;
                    curRes = [ repmat( [ i , dim , eps , curMu ]  , [size( res , 1 ) , 1 ] ) ...
                        res ];
                    ADFemaleModelResult = [ ADFemaleModelResult ; curRes];
            end
        end
    end
end
%% save all the data
if GROUP_SIZES
    name = 'unsupervisedResult_group_size';
else
    name = 'unsupervisedResult';
end
save( fullfile( setName , name ) , 'ADMaleModelResult' , 'ADFemaleModelResult' , ...
    'FemaleTotError' , 'MaleTotError' , ...
    'unsupervisedResult2_10' , ...
    'allClusterComposition' , ...
    'reduceMethods' , 'Methods_unsupervised', ...
    'MU', 'allClust_2_10');
