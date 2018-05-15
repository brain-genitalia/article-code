function [ optimalK , values , groupsIntoClasses , allClust , clusterComposition] = tryMyCluster( data , groups , clust)

global Methods_unsupervised
criteria = {'CalinskiHarabasz' , 'DaviesBouldin' , 'gap' , 'silhouette'};
succRate = [];
optimalK = [];
groupsIntoClasses = [] ;
values = [] ;
allClust = [] ;
clusterComposition = cell(0);
for i = 1 : length( Methods_unsupervised )
    m = Methods_unsupervised{i};
    curValues = [] ; 
    curOptimal = [] ; 
    groupsIntoClass = cell( 1 , length( clust ) );
    for c = clust
        if strcmp( m , 'gaussian' ) && size( data , 2 ) > 8
            clusters = nan( size( groups ) );
            groupsIntoClass{c + 1 - clust(1 )} = nan( c , length( unique( groups ) ));
        else
            try
                [ clusters , groupsIntoClass{c + 1 - clust(1 )} ]= trySpecificMehodCLuster( data , c , m , groups);
                clusterComposition{ length(clusterComposition) + 1 } = groupsIntoClass{c + 1 - clust(1 )} ;
            catch
                clusters = nan( size( groups ) );
                groupsIntoClass{c + 1 - clust(1 )} = nan( c , length( unique( groups ) ));
            end
        end
        allClust = [ allClust , clusters ];
        if length( clust ) > 1
            curValues = [curValues ; evaluateInternal( data , clusters )];
        end
    end
    if length( clust ) > 1
        [ ~ , curOptimal ] = max( curValues );
        values = [ values ; curValues ] ;
        optimalK = [ optimalK , clust(curOptimal) ] ;
        groupsIntoClasses = [ groupsIntoClasses ,  groupsIntoClass( curOptimal ) ];
    else
        optimalK = clust;
        values = -1;
        groupsIntoClasses = [ groupsIntoClasses ,  groupsIntoClass ];
    end
end

values = values';
values = values(:)';

end

function [clusters , groupsIntoClass ] = trySpecificMehodCLuster( data , cl , m , groups)

switch m 
    case 'kmeans'
        clusters = tryKmeans( data , cl);
    case 'linkage'
        clusters = tryHierarchical( data , cl );  
    case 'dbscan'
        distance = pdist2( data , data );
        clusters = DBSCAN( data , prctile( distance(:) , 1 ) , 0.1 * size( data , 1 ) );
    case 'gaussian'
        obj = fitgmdist(data,cl);
        clusters = cluster(obj,data);
end

c = unique( clusters );
groupsIntoClass = nan( length( c ) , length( unique( groups ) )  );
for i = 1 : length( c )
    for j = unique( groups)'
        groupsIntoClass( c( i ) , j ) = sum( groups == j & clusters == c( i ) );        
    end
end


end

function clusters = tryKmeans( data , cl)


clusters = kmeans(data , cl ,...
    'Replicates',10,...
    'distance' , 'sqEuclidean');
end

function clusters = tryHierarchical( data , cl)

clustTree = linkage(data,'ward' , 'euclidean');

clusters = cluster(clustTree,'maxclust',cl);

end

function values = evaluateInternal( data , clusters )

P = size( data , 2 );
n = size( data , 1 );
centerAll = mean( data );
cl = unique ( clusters )';
NC = length( cl );
centers = nan( length( cl ) , P );
for c = cl
    centers( c , : ) = mean( data( clusters == c , :) );
end

%% Root-mean-square standard deviation (RMSSTD) - elbow

mone = 0 ;
mechane = 0 ;
for c = cl
    curData = data( clusters == c , :);
    p = pdist2( curData , centers( c , : ) ).^2 ;
    mone = mone + sum( p );
    mechane = mechane + size( curData , 1 ) - 1;
end

RMSSTD = ( mone / ( mechane * P ) )^2;

%% R-squared (RS) - elbow

mone1 = sum( pdist2( data , centerAll ).^2 );
mone2 = 0 ;
for c = cl
    curData = data( clusters == c , :);
    p = pdist2( curData , centers( c , : ) ).^2 ;
    mone2 = mone2 + sum( p );
end
RS = (mone1 - mone2 ) / mone1;

%% Modified Hubert GAMMA statistic (GAMMA) - elbow

distXY = pdist2( data , data );
distClust = pdist2( centers , centers );
distCenters = nan( size( distXY ) );
for i = 1 : length( clusters )
    for j = 1 : length( clusters )
        distCenters( i , j ) = distClust( clusters( i ) , clusters( j ) );
    end
end

R = 2 / ( n * (n-1 ) ) * sum2(distXY .* distCenters );

%% CalinskiHarabasz index (CH) - max

times = hist( clusters , max( clusters ) );
mone = sum( times' .* (pdist2( centers , centerAll ) .^ 2) ) / ( NC - 1 );
mechane = 0 ;
for c = cl
    curData = data( clusters == c , :);
    p = pdist2( curData , centers( c , : ) ).^2 ;
    mechane = mechane + sum( p );
end
mechane = mechane / ( n - NC );

CH = mone / mechane;

%% index(I)

mone = sum ( pdist2( data , centerAll ) );
mechane = 0 ;
for c = cl
    curData = data( clusters == c , :);
    p = pdist2( curData , centers( c , : ) );
    mechane = mechane + sum( p );
end

I = (1 / NC) * ( mone / mechane ) * max2( distClust );
I = I ^ P ;

%% Dunn’s indices (D)

d = distXY .* (distCenters > 0 );
mone = min2( d ( d > 0 ) );
mechane = 0;
for c = cl
    curData = data( clusters == c , :);
    m = max2( pdist2( curData , curData ) );
    mechane = max( mechane , m );
end

D = mone / mechane;

%% Silhouette index (S) 

s = silhouette(data , clusters );
times = [];
for c = cl
    times( c ) = sum( clusters == c );
end
s = s ./ times( clusters )';
S = sum( s ) / NC;

%% Davies-Bouldin index (DB) 

summing = 0 ;

for c = cl
    curData = data( clusters == c , : );
    s = 1 / size( curData , 1 ) * sum (pdist2( curData , centers( c , : ) ) ) ;
    curMax = 0 ;
    for j = cl
        if c == j 
            continue
        end
        curData_j = data( clusters == j , : );
        s_j = 1 / size( curData_j , 1 ) * sum (pdist2( curData_j , centers( j , : ) ) ) ;
        mone = s_j + s;
        mechane = distClust( c , j );
        curMax = max( curMax , mone / mechane );
    end
    summing = summing + curMax;
end

DB = summing / NC;
% to maximize
DB = 1 / DB;

%% Xie-Beni index (XB)
mone = 0 ;
for c = cl
    curData = data( clusters == c , :);
    p = pdist2( curData , centers( c , : ) ).^2 ;
    mone = mone + sum( p );
end
d = distClust.^2;
mechane = n * min2(d(d > 0 ) ); 

XB = mone / mechane;
% to maximize
XB = 1 / XB;
%% SD 



%%
% values = [ RMSSTD , RS , R , CH , I , D , S , DB , XB ];
values = [ CH , I , D , S , DB , XB ];
end