function [ res ,  totError , baseMat] = tryAnnomalyDtection( data , groups , CUR_GROUP)

otherGroup = 1;
if CUR_GROUP == 1
    otherGroup = 2;
end
res = [] ;
allError = [] ;
%% calculate a base group
one = find( groups == CUR_GROUP );
r = 1 : round( 0.5 *  length( one  ) );
baseInd = one( r );
otherInd = ~ismember( 1 : length( groups ) , baseInd );
otherCurGroup = find( otherInd' & groups == CUR_GROUP  );
l = length( otherCurGroup );
other = find( otherInd' & groups ~= CUR_GROUP ) ;

otherInd = other( 1 : l );
baseMat = data( baseInd , : );

otherInd = [ otherInd ; otherCurGroup ];
otherMat = data( otherInd , : );
otherGroups = groups(otherInd  );

res = [] ;
% number of nearest neghiber
for k = 10: 5 : 50
    [ ~ , interDist ] = knnsearch( baseMat , baseMat, 'K' , k + 1) ;
    m = mean( interDist( : , 2 : end ) , 2 );
    
    [ ~ , outerDist ] = knnsearch( baseMat , otherMat , 'K' , k );
    otherBaseMean = mean( outerDist , 2 );
    
    % percentile
    for perc = 20 : 5 : 100
        thresh = prctile( m( : ) , perc );
        %% find density
        myGroups = CUR_GROUP * ones( size( otherInd ) );
        myGroups( thresh < otherBaseMean ) = otherGroup;
        cfMat = confusionmat(myGroups,otherGroups,'order',unique( otherGroups ));
        s1 = cfMat( 1 , 1 ) / sum( cfMat(: , 1 ) );
        s2 = cfMat( 2 , 2 ) / sum( cfMat(: , 2 ) );
        res = [res ; k , perc , s1 , s2 ];
        curError = myGroups ~= otherGroups;
        allError(: , end + 1 ) = curError;
    end
end

totError = nan( length( groups ) , size( allError , 2 ) );
totError(otherInd , : ) = allError;

end