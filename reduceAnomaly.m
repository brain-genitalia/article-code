function a = reduceAnomaly( a )
% reduce the number of lines. take only for different values of reduc
% dimensions method, number of dims , epsilon and mu
first = unique( a( : , 1 ) );
second = unique( a( : , 2 ) );
third =  unique( a( : , 3 ) );
fourth =  unique( a( : , 4 ) );
res = [] ;
for numberOfClusters = 1 : length( first )
    f = first( numberOfClusters );
%     for j = 1 : length( second )
%         s = second( j );
%         for k = 1 : length( third )
%             th = third( k );
%             for m = 1 : length( fourth )
%                 fo = fourth( m );
%                 curr = a( a(: , 1 ) == f & a(: , 2 ) == s & a(: , 3 ) == th & a(: , 4 ) == fo, : );
                curr = a( a(: , 1 ) == f , : );
                c = curr( : , [ end - 1 : end ] );
                [ ~ , ind ] = max( mean( c ,  2 ) );
                if ~isempty( ind )
                    res = [ res ; [ f  ,c( ind , : ) ] ;];
                end
%             end
%         end
%     end
end
a = res ;
end