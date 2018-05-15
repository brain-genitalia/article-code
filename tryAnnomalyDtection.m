function [ res , resLU , totError , baseMat] = tryAnnomalyDtection( data , groups , CUR_GROUP, stop)

global times RAND
if nargin < 4
    baseMat = [] ;    
    stop = 0;
end
if stop
    res = [] ;
    totError = [] ;
    resLU = [] ;
end
otherGroup = 1;
if CUR_GROUP == 1
    otherGroup = 2;
end
res = [] ;
allError = [] ;
for i = 1 : times
    %% rand a base group
    one = find( groups == CUR_GROUP );
    if RAND
        r = randperm( length( one ) , round( 0.5 *  length( one  ) ) );
    else
        r = 1 : round( 0.5 *  length( one  ) );
    end
    baseInd = one( r );
    otherInd = ~ismember( 1 : length( groups ) , baseInd );
    otherCurGroup = find( otherInd' & groups == CUR_GROUP  );
    l = length( otherCurGroup );
    other = find( otherInd' & groups ~= CUR_GROUP ) ;
    if RAND
        otherInd = other( randperm( length( other ) , l ) );
    else
        otherInd = other( 1 : l );
    end
    baseMat = data( baseInd , : );
    if stop
        return;
    end
    otherInd = [ otherInd ; otherCurGroup ];
    otherMat = data( otherInd , : );
    otherGroups = groups(otherInd  );
    
    res = [] ;
    resLU = [] ;
    for LU = [ false ]
        if ~LU
            for k = 10: 5 : 50
                [ ~ , interDist ] = knnsearch( baseMat , baseMat, 'K' , k + 1) ;
                m = mean( interDist( : , 2 : end ) , 2 );
                
                [ ~ , outerDist ] = knnsearch( baseMat , otherMat , 'K' , k );
                otherBaseMean = mean( outerDist , 2 );
                
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
            
        else
            score = tryAnnomalyDtectionLU( baseMat , otherMat );
            myGroups = CUR_GROUP * ones( size( otherInd ) );
            myGroups( median( score ) < score ) = otherGroup;
            cfMat = confusionmat(myGroups,otherGroups,'order',unique( otherGroups ));
            s1 = cfMat( 1 , 1 ) / sum( cfMat(: , 1 ) );
            s2 = cfMat( 2 , 2 ) / sum( cfMat(: , 2 ) );
            resLU = [resLU ; s1 , s2 ];
        end
    end
end
    totError = nan( length( groups ) , size( allError , 2 ) );
    totError(otherInd , : ) = allError;

end