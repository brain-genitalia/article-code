global iter
global FEATURE_SELECTION
EPSILONS = 14.^( 2.8 : 0.2  : 3.2 );
MU = 10.^(-8 : 2 : -2);
global all_dims
%% try Classify , k folding
% 3 - unsuperVised
% 4 - annomaly detection
such = [ 3 4];
ADMaleModelResult = [] ;
ADFemaleModelResult = [];
ADFemaleModelResultLU = [] ;
ADMaleModelResultLU = [] ;
unsupervisedResult3_11 = [];
unsupervisedValues3_11 = [] ;
groupsIntoClustering3_11 = [] ;
unsupervisedResult2_10 = [];
unsupervisedValues2_10 = [] ;
groupsIntoClustering2_10 = [] ;
unsupervisedResult2 = [];
unsupervisedValues2 = [] ;
groupsIntoClustering2 = [] ;
FemaleTotError = [] ;
MaleTotError = [] ;
allCluster2Linkage = [] ;
eigenValues = [] ;
allClusterComposition = [];
allClust_2_10 = {};
global times reduceMethods
global Methods_unsupervised
global RAND % in anomaly detection
global GROUP_SIZES
RAND = 0;
reduceMethods = {'none' , 'pca' , 'dm' , 'dmC' , 'PDME' , 'ICPQR' , 'ICPQR_data' };
Methods_unsupervised = {'kmeans' , 'linkage' };

if ~exist('setName' , 'var' )
    setName = 'GSP_VBM';
end

allClustering = cell( 1 , length( Methods_unsupervised ) );

load ( fullfile( setName, 'allDataGroupsOriginal.mat' ) );

load dims;
if GROUP_SIZES
    allGroups = double( allFullSize < median( allFullSize) )  + 1;
end
times = 1;
originalData = allData;

for i = 1 : length( reduceMethods )
    reduce = reduceMethods{ i };
    normData = zscore( allData );
    if strcmp( reduce , 'dmC' ) || strcmp( reduce , 'pca' ) || strcmp( reduce , 'dm' ) || strcmp( reduce , 'none' )
        mu = 0;
        eps = 0;
        if strcmp( reduce , 'dmC' )
            eps = estimate_epsilon( ...
                pdist2( normData , normData , 'correlation' ) );
        elseif strcmp( reduce , 'dm' )
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
        if FEATURE_SELECTION
            name = sprintf('data/method is %s , epsilon is %s , mu is %s select %d features.mat' , reduce , num2str(eps) , num2str(curMu) , numberOfFeature);    
        else
            name = sprintf('data/method is %s , epsilon is %s , mu is %s .mat' , reduce , num2str(eps) , num2str(curMu));
        end
        name = fullfile( setName , name );
        if exist(name , 'file' )
            a = load( name );
            reducingData = a.reducingData;
        else
            continue
            reducingData = getReducingData( normData , reduce , 0 , eps , curMu );
            save(name , 'reducingData' );
        end
        if strcmp( reduce , 'PDME') || strcmp( reduce , 'ICPQR')
            reducingData = reducingData(: , 2 : end );
        end
        if isempty( reducingData )
            continue
        end
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
        for dim = maxDim
            if dim < 0
                break;
            end
            curData = reducingData( : , 1 : dim );
            for p = such
                switch p
                    case 3
                        [ optimalK , values , groupsIntoClasses , allClust , clusterComposition] = tryMyCluster( curData , allGroups , 2 : 10);
                        allClusterComposition = [allClusterComposition ; clusterComposition ];
                        groupsIntoClustering2_10 = [ groupsIntoClustering2_10 ; groupsIntoClasses ];
                        unsupervisedValues2_10 = [ unsupervisedValues2_10 ; values ];
                        allClust_2_10{end+1} = allClust;
                        unsupervisedResult2_10 = [ unsupervisedResult2_10 ; i , dim , eps , curMu , optimalK];
                   case 4
                        [ res , resLU , totError ] = tryAnnomalyDtection( curData , allGroups , 1);
                        MaleTotError = [MaleTotError , totError] ;
                        curRes = [ repmat( [ i , dim , eps , curMu ]  , [size( res , 1 ) , 1 ] ) ...
                            res ];
                        ADMaleModelResult = [ ADMaleModelResult ; curRes];
                        curResLU = [ repmat( [ i , dim , eps , curMu ]  , [size( resLU , 1 ) , 1 ] ) ...
                            resLU ];
                        ADMaleModelResultLU = [ ADMaleModelResultLU ; curResLU];%
                        [ res , resLU , totError ] = tryAnnomalyDtection( curData , allGroups , 2);
                        FemaleTotError = [FemaleTotError , totError] ;
                        curRes = [ repmat( [ i , dim , eps , curMu ]  , [size( res , 1 ) , 1 ] ) ...
                            res ];
                        ADFemaleModelResult = [ ADFemaleModelResult ; curRes];
                        curResLU = [ repmat( [ i , dim , eps , curMu ]  , [size( resLU , 1 ) , 1 ] ) ...
                            resLU ];
                        ADFemaleModelResultLU = [ ADFemaleModelResultLU ; curResLU];
                end
            end
        end
    end
end
if GROUP_SIZES
    save( fullfile( setName , 'unsupervisedResultAutoEpsilonGroupsSizes10' ) , 'ADMaleModelResult' , 'ADFemaleModelResult' , ...
        'FemaleTotError' , 'MaleTotError' , ...
        'groupsIntoClustering2_10' , 'unsupervisedResult2_10' , 'unsupervisedValues2_10' , ...
        'groupsIntoClustering3_11' , 'unsupervisedResult3_11' , 'unsupervisedValues3_11' , ...
        'groupsIntoClustering2' , 'unsupervisedResult2' , 'unsupervisedValues2' , ...
        'allClusterComposition' , 'allCluster2Linkage' , ...
        'reduceMethods' , 'Methods_unsupervised' , 'ADMaleModelResultLU' , ...
        'ADFemaleModelResultLU' , 'allClustering' , 'MU');
else
    save( fullfile( setName , 'unsupervisedResultAutoEpsilon_May18' ) ,  'ADMaleModelResult' , 'ADFemaleModelResult' , ...
        'FemaleTotError' , 'MaleTotError' , ...
        'groupsIntoClustering2_10' , 'unsupervisedResult2_10' , 'unsupervisedValues2_10' , ...
        'groupsIntoClustering3_11' , 'unsupervisedResult3_11' , 'unsupervisedValues3_11' , ...
        'groupsIntoClustering2' , 'unsupervisedResult2' , 'unsupervisedValues2' , ...
        'allClusterComposition' , 'allCluster2Linkage' , ...
        'reduceMethods' , 'Methods_unsupervised' , 'ADMaleModelResultLU' , ...
        'ADFemaleModelResultLU' , 'allClustering' , 'MU' , 'allClust_2_10');
end