function [ reducingData ] = getReducingData( data , method , epsilon , mu)

reducingData = reducing( data , method , epsilon , mu);

end


function reducingData = reducing( data , method , epsilon , mu)
switch method
    case 'none'
        reducingData = data ;
    case 'pca'
        [ ~ , reducingData , ~ , ~ , ~  ] = pca(data);
    case 'dm'
        dists = pdist2( data , data );
        reducingData = DM( dists , epsilon );
    case 'ICPQR'
        reducingData = ICPQR_DM(data,epsilon,mu);
    case 'ICPQR_data'
        reducingData = ICPQR(data',mu);
        reducingData = reducingData';
    case 'PDME'
        [~,~, reducingData] = PDMEmbedding_Opt_MRG_v2...
            (data , epsilon , mu);
end

end
