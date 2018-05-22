function dim = findMaxDim( vals )
try
dify = diff( vals );
difx = diff( [ 1 : length( vals ) ] / length( vals ) );

m = dify' ./ -difx;

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