function [ allClust , clusterComposition] = tryMyCluster( data , groups , clust)

global Methods_unsupervised
allClust =[];
clusterComposition = cell(0);
for i = 1 : length( Methods_unsupervised )
    m = Methods_unsupervised{i};
    groupsIntoClass = cell( 1 , length( clust ) );
    for c = clust
        try
            [ clusters , groupsIntoClass{c + 1 - clust(1 )} ]= trySpecificMehodCLuster( data , c , m , groups);
            clusterComposition{ length(clusterComposition) + 1 } = groupsIntoClass{c + 1 - clust(1 )} ;
        catch
            clusters = nan( size( groups ) );
            groupsIntoClass{c + 1 - clust(1 )} = nan( c , length( unique( groups ) ));
        end
        allClust = [ allClust , clusters ];
    end
end

end

function [clusters , groupsIntoClass ] = trySpecificMehodCLuster( data , cl , m , groups)

switch m 
    case 'kmeans'
        clusters = tryKmeans( data , cl);
    case 'linkage'
        clusters = tryHierarchical( data , cl );  
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
