function [ reducingData , resStruct] = getReducingData( data , method , explore , epsilon , mu)

if ~exist('explore' , 'var' )
    explore = 0;
end

[ reducingData , resStruct]= reducing( data , method , explore , epsilon , mu);

end


function [ reducingData , resStruct ]= reducing( data , method , explore , epsilon , mu)
resStruct = [];
switch method
    case 'none'
        reducingData = data ;
    case 'pca'
        [ ~ , reducingData , latent , ~ , explained  ] = pca(data);
        resStruct.reducingData = reducingData;
        if explore
            exploring( latent );
        end
    case 'dm'
        dists = pdist2( data , data );
%         dists = dists / max( dists(:));
        [ resStruct.reducingData , resStruct.eigenValuesReduce ] = DM( dists , epsilon );
        if explore
            exploring( diag( DD ) );
        end
        reducingData = resStruct.reducingData;
    case 'dmC'
        dists = pdist2( data , data , 'correlation' );
%         dists = dists / max( dists(:));
        [ resStruct.reducingData , resStruct.eigenValuesReduce ] = DM( dists , epsilon );
        if explore
            exploring( diag( DD ) );
        end
        reducingData = resStruct.reducingData;
    case 'ICPQR'
        [resStruct.reducingData, pi, s, FMdict, resStruct.dict , resStruct.fullMap , ...
            resStruct.disortion ] = ICPQR_DM(data,epsilon,mu);
        reducingData = resStruct.reducingData;
    case 'ICPQR_data'
        [reducingData, resStruct.dict , ...
            resStruct.disortion ] = ICPQR(data',mu);
        resStruct.reducingData = reducingData';
        reducingData = reducingData';
%         if explore
%             exploring( diag( s ) );
%         end
    case 'PDME'
        [A,B, resStruct.reducingData,resStruct.dict,Iord,resStruct.eigenValuesRed , resStruct.distortion] = PDMEmbedding_Opt_MRG_v2...
            (data , epsilon , mu);
        reducingData = resStruct.reducingData;
        if explore
            exploring( diag( s ) );
        end
end

end

function exploring ( eigen  )
% exploring the eigen values

figure
plot( eigen / max( eigen ) );
title('EIgen values ( after divide by the largest eigen value )');
% figure
% plot( cumsum( eigen ) / sum( eigen ) );
% title('CDF of the eigen values');

end