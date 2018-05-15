function dim = findMaxDim( vals )
try
dify = diff( vals );
difx = diff( [ 1 : length( vals ) ] / length( vals ) );

m = dify' ./ -difx;

% figure; hold on; plot( [ 1 : length( vals ) ] / length( vals ) , vals , 'b.' )
% plot( 42/length( vals ) , vals( dim ) , 'ro' , 'MarkerSize' , 20)
% xlabel( 'normalized index');
% ylabel( 'normalized eigenvalues');

windowSize = 3;
if length( vals ) < 3 * windowSize
    dim = length( vals );
    return
end
slope = zeros( size( m ) );
for i = windowSize + 1 : length( m ) - windowSize
    slope( i ) = mean( m(i - windowSize: i + windowSize));
end
[~ , dim ] = min( abs( slope - 1 ) );
catch
    dim = -1;
end

end