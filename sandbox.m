global times GROUP_SIZES 
global fullTable ;

times = 1;
SAVE =0;
if ~exist('setName' , 'var' )
    setName = 'GSP_VBM';
end
FEATURE_SELECTION = 0;
%% unsupervised
if GROUP_SIZES
    imagesDir = 'imagesVolume';
    load( fullfile( setName , 'unsupervisedResultAutoEpsilonGroupsSizes10' ));
else
    imagesDir = 'imagesNew';
    try
        load( fullfile( setName , 'unsupervisedResultAutoEpsilon_May18'));
    catch
        try
            load( fullfile( setName , 'unsupervisedResultAutoEpsilon10' ));

        catch
            load( fullfile( setName , 'unsupervisedResultAutoEpsilon') );
        end
    end
end
%% print histogram
% c2 = unsupervisedResult2_10( : , [ 5 : end ] );
% c3 = unsupervisedResult3_11( : , [ 5 : end ] );
% good = ~( c2==10 & c3 == 11 );
% % good = ones( size( c2 ) );
% evaluationAmount = size( c2 , 2 ) / 2 ;
% 
% hireClustering = c2(: , end/2 + 1 : end );
% hireGood = good( : , end/2 + 1 : end );
% 
% kmeansClustering = c2(: , 1 : end/2 );
% kmeansGood = good( : , 1 : end/2 );
% 
% [nelements,centers]  = hist( hireClustering(:) , [ min2( hireClustering) : max2(hireClustering) ] );
% figure
% bar(centers,nelements , 'k')
% 
% title('Histogram of the number of cluster before filtering - hierarchical algorithm')
% set( gcf, 'PaperPositionMode' , 'auto');
% name = fullfile( setName , imagesDir , 'clustering' , ...
%     'unsupervised_NumOfClassHistogram_beforeFiltering_hierarchical.png' );
% if SAVE
%     screen2png( name );
% end
% 
% [nelements,centers]  = hist( hireClustering( hireGood ) , [ min2( hireClustering) : max2(hireClustering) ]);
% figure
% bar(centers,nelements , 'k')
% 
% title('Histogram of the number of cluster after filtering - hierarchical algorithm')
% name = fullfile( setName ,imagesDir , 'clustering' , ...
%     'unsupervised_NumOfClassHistogram_afterFiltering_hierarchical.png' );
% if SAVE
%     screen2png( name );
% end
% 
% 
% 
% [nelements,centers]  = hist( kmeansClustering(:) ,[ min2( kmeansClustering) : max2(kmeansClustering) ] );
% figure
% bar(centers,nelements , 'k')
% 
% title('Histogram of the number of cluster before filtering - k-means algorithm')
% set( gcf, 'PaperPositionMode' , 'auto');
% name = fullfile( setName , imagesDir , 'clustering' , ...
%     'unsupervised_NumOfClassHistogram_beforeFiltering_kmeans.png' );
% if SAVE
%     screen2png( name );
% end
%      
% [nelements,centers]  = hist( kmeansClustering( kmeansGood) , [ min2( kmeansClustering) : max2(kmeansClustering) ] , 'FaceColor','k' );
% figure
% bar(centers,nelements , 'k')
% title('Histogram of the number of cluster after filtering - k-means algorithm')
% name = fullfile( setName , imagesDir , 'clustering' , ...
%     'unsupervised_NumOfClassHistogram_afterFiltering_kmeans.png' );
% if SAVE
%     screen2png( name );
% end

% return
%% plot to excel cahnce of male/male F/F M/F to be in one cluster
g = allClusterComposition;
numberOfCLusters = [3:10];
colsForalgo = size( g , 2 ) / 2;
reduceM = reduceMethods;
reduceM( 4) = [];
currentTable = cell(0) ;
figure('outerposition' , [0 0 900 900]); hold on;
colors = [ 0.5 0.5 1; 1 0 0; 0 1 0 ; 0 0 1 ; 1 0.5 0 ; 1 0 1; 0 1 1 ; 0 0 0 ; 0.5 0.5 0.5 ];
zura = 'ds';
legVal = cell( 0 );
UNDER_OVER_MEDIAN = 0;

csv_table = [];
for numOfClusters = numberOfCLusters
    methodUniq = unique( unsupervisedResult2_10(: , 1 ) )';
    methodUniq( methodUniq == 4 ) = []; %remove dmC
    curPlotX = [];
    curPlotY = [];
    x_prop = [] ; y_prop = [];
    for clMethod = 1 : 2
        len = length( methodUniq );
        h = zeros( len , numOfClusters );
        hFemales = zeros( len , numOfClusters );
        counter = 0;
        MM = nan( length(methodUniq) , 1);
        FF = nan( length(methodUniq) , 1);
        MF = nan( length(methodUniq) , 1);
        for i = methodUniq
            counter = counter + 1;
            curComposition = g( unsupervisedResult2_10(: , 1) == i , colsForalgo * (clMethod - 1 ) + numOfClusters - 1 );
            finalGrade = 0;
            win = [];
            for com = 1 : length( curComposition )                
                cur = curComposition{ com };
                curPerc = cur / (sum2( cur ) /2);
                grade = mean( sum( cur , 2 ) / sum2( cur) .* abs ( curPerc(: , 1 ) - curPerc(: , 2 ) ) );
                if finalGrade < grade
                    win = cur;
                    winPerc = curPerc;
                    grade = finalGrade;
                end
            end           
            cur = win;
            M = cur(: , 1 );
            F = cur(: , 2 );
            if UNDER_OVER_MEDIAN
                is_larger = load( fullfile( setName , 'is_large_than_median' ) );
                is_larger = is_larger.is_large_than_median_result;
                cur_clust = allClust_2_10{i};
                cur_clust = cur_clust( : , numOfClusters - 1 + (clMethod - 1 ) * 9 );
                cur = [];
                for p = 1 : numOfClusters
                    cur = [cur ; sum(cur_clust == p & is_larger) , sum(cur_clust == p & ~is_larger)];
                end
            end
            M = cur(: , 1 );
            F = cur(: , 2 );
            
            y_prop =[y_prop ; max( cur , [] , 2 ) ./ sum( cur , 2 ) ] ;
            x_prop = [x_prop ; sum( cur , 2 )];
            Grade = (F-M) ./ sqrt(sum( cur , 2 ));
            Sizes = sum( cur , 2 );% / sum2( cur )  ;
            curPlotX = [ curPlotX ; Grade ] ;
            curPlotY = [ curPlotY ; Sizes ] ;
            csv_table = [ csv_table ; 
                repmat( [numOfClusters , clMethod , i ] , numOfClusters , 1) , Sizes , M , F ];
%             if clMethod == 1
%                 algo = 'k-means';
%             else
%                 algo = 'hierarchical';
%             end
            
            curPerc = winPerc;
            m = curPerc( : , 1 );
            f = curPerc( : , 2 );
            MM(counter ) = sum( m .* m );
            FF(counter ) = sum( f .* f );
            MF(counter ) = sum( m .* f );
        end 
        currentTable =[ currentTable , [ { sprintf('%.3f (%.4f)', mean( MF) , std( MF)) } ;...
            { sprintf('%.3f (%.4f)', mean( FF) , std( FF) )} ; ...
            { sprintf('%.3f (%.4f)', mean( MM) , std( MM) )} ] ]; 
%         if clMethod == 1
%             fileName = sprintf('%s_%d_K_means.xlsx', setName , GROUP_SIZES);
%         else
%             fileName = sprintf('%s_%d_hierarchical.xlsx', setName , GROUP_SIZES);
%         end
%         sheet = sprintf( '%d' , numOfClusters );
%         b = {'MM' , 'FF' , 'MF' };
%         xlswrite(fileName, b , sheet ,'B1');
%         xlswrite(fileName, reduceM' , sheet ,'A2');
%         xlswrite(fileName, [ MM FF MF], sheet ,'B2');
    end    
%     plot( curPlotY , curPlotX , 'LineStyle' , 'none', ...
%                 'Color' , colors( numOfClusters - min(numberOfCLusters) + 1 , : ), 'Marker',  'o' , 'MarkerSize' , 8)
    plot( x_prop , y_prop, 'LineStyle' , 'none', ...
                'Color' , colors( numOfClusters - min(numberOfCLusters) + 1 , : ), 'Marker',  'o' , 'MarkerSize' , 8)
%     legVal = [legVal , sprintf('%d clusters', numOfClusters) ];
            
end
ylim( [ 0.5 1] )
set( gca , 'FontSize', 30 )
% % legend( legVal , 'Location','northeastoutside' );
% title( setName );
% disp( setName  )
% % if GROUP_SIZES
% %     name =  fullfile( setName , imagesDir , 'clustering' , sprintf('%s_group_size_legend_new_clusterEquality_no_axis_limit_absolute_number_diff_value_legend.png' , setName ) );
% % else
% %     name =  fullfile( setName , imagesDir , 'clustering' , sprintf('%slegend_new_clusterEquality_no_axis_limit_absolute_number_diff_value_legend.png' , setName ) );
% % end
xlabel('Number of participants in the cluster')
ylabel('Sex disparity')
if UNDER_OVER_MEDIAN
    name = fullfile('C:\Users\user\teza\myCode\MachineLearning\brains\appendix\p1_q1', sprintf('%s_prop_brain_size.png' , setName ));
    ylabel('Size disparity')

else
    name = fullfile('C:\Users\user\teza\myCode\MachineLearning\brains\appendix\p1_q1', sprintf('%s_prop.png' , setName ));
end
% % name =  fullfile( setName , imagesDir , 'clustering' , sprintf('%s_prop.png' , setName ) );
% screen2png(name )
% if GROUP_SIZES
%     xlswrite([setName , '_clusters_group_size.csv'] , csv_table ) 
% else
%     xlswrite([setName , '_clusters.csv'] , csv_table )
% end
disp(setName)
fullTable = [ fullTable ; currentTable ];
return
%% plot groups for final number of classes
g = allClusterComposition;
numberOfCLusters = [ 3 4];
colsForalgo = 9;
% 
% for numOfClusters = numberOfCLusters
%     methodUniq = unique( unsupervisedResult2_10(: , 1 ) )';
%     methodUniq( methodUniq == 4 ) = []; %remove dmC
%     for clMethod = 1 : 2
%         len = length( methodUniq );
%         h = zeros( len , numOfClusters );
%         hFemales = zeros( len , numOfClusters );
%         counter = 0;
%         for i = methodUniq
%             counter = counter + 1;
%             curComposition = g( unsupervisedResult2_10(: , 1) == i , colsForalgo * (clMethod - 1 ) + numOfClusters - 1 );
%             finalGrade = 0;
%             win = [];
%             for com = 1 : length( curComposition )                
%                 cur = curComposition{ com };
%                 curPerc = cur / (sum2( cur ) /2);
%                 grade = mean( sum( cur , 2 ) / sum2( cur) .* abs ( curPerc(: , 1 ) - curPerc(: , 2 ) ) )
%                 if finalGrade < grade
%                     win = cur;
%                     winPerc = curPerc;
%                     grade = finalGrade;
%                 end
%             end           
%             cur = win;
%             curPerc = winPerc * 100;
%             h( counter  , : ) = sum(curPerc(: , [1 , 2] ) , 2 )';
%             hFemales( counter , : ) = curPerc(: , 2 )';
%         end
%         handle = figure('units' , 'normalized' , 'outerposition' , [0 0 1 1]);
%         hold on;
%         bar( h  , 'b');
%         bar( hFemales , 'r');
%         x = 1 : 6;
%         set( gca, 'xtick' , x );
%         set( gca, 'xticklabel' , {'none' , 'PCA' , 'diffusion map' ...
%             , 'isometric diffusion map' ,'ICPQR' , 'ICPQR data'  } );
%         set( gca , 'FontSize', 10 );
%         if clMethod == 1
%             algo = 'k-means';
%         else
%             algo = 'hierarchical';
%         end
%         title( sprintf('Divide to %d cluster by %s algorithm. The amount in each cluster, man (blue) and female (red)' , numOfClusters , algo) );
%         name =  fullfile( setName , imagesDir , 'clustering' , sprintf('Amount_in_clusters_man(blue)_female(red)_%d_clus_%s_algorithm.png' , numOfClusters , algo ) );
%         if exist(name , 'file' )
%             delete(name);
%             pause(1)
%         end
%         axis( [ 0 7 0 200] )
%         if SAVE
%             screen2png( name );
%         end
%     end    
% end
% 
% return;
%% process the hierarchical.
% c2 = unsupervisedResult2_10( : , [ 5 : end ] );
% c3 = unsupervisedResult3_11( : , [ 5 : end ] );
% good = ~( c2==10 & c3 == 11 );
% g = groupsIntoClustering2_10;
% hireClustering = g(: , end/2 + 1 : end );
% hireGood = good( : , end/2 + 1 : end );
% 
% kmeansClustering = g(: , 1 : end/2 );
% kmeansGood = good( : , 1 : end/2 );
% 
% maxClusterNumber = 6;
% for method = 1 : 2
%     if method == 1
%         result = embededClusters( hireClustering , hireGood);
%         mString = 'Hierarchical';
%     else
%         result = embededClusters( kmeansClustering , kmeansGood);
%         mString = 'K-means';
%     end
%     result = unique( result , 'rows' );
%     % in the result there is one row per partition
%     % 1. the first colume is the number of clustering
%     % 2. the second is the line in g (to get unique rows);
%     % 3. the thirth in how many clusters we pass the half of the data
%     % 4. and the fourth if this typical cluster is to the two gender
%     % 5. then is which gender pass the half more speed (1-males, 2-femals,
%     %       3-equall.
%     % 6. how many clust is took
%     % 7. then is the ratio of males in the pass
%     % 8. then is the ratio of females in te pass
%     % 9. in divide to 3 cluster. if in the large cluster there are more males
%     %   from every other cluster
%     % 10. if in the two largest cluster there are more than hakf of males and
%     %   females
%     % 11. the minimum rate of males in the largest to cluster (minimum above
%     %   the two largest clusters
%     % 12. like 11 but max
%     % 13. if two largest cluster contain at least more of the femals
%     % 14. what is the rate of males in the two largest custer
%     numberOfCluster = unique( result(result(: , 1 ) <= maxClusterNumber , 1 ) )';
%     
%     typical = nan( size( numberOfCluster ) );
%     typical2Gender = nan( size( numberOfCluster ) );
%     whoPassHistograma = nan( length( numberOfCluster ) , 3 );
%     clustersToPassHalfOneGenderHistograma = nan( length( numberOfCluster ) , 3 );
%     clustersToPassHalfAllHistogram = nan( length( numberOfCluster ) , 3 );
%     
%     counter = 1;
%     for i = numberOfCluster
%         cur = result( result(: , 1 ) == i , : );
%         numberOftypical = sum(cur (: , 3 ) == 1 );
%         typical( counter ) = numberOftypical / size( cur , 1 );
%         typical2Gender( counter ) = sum( cur(: , 4 ) == 1) / numberOftypical;
%         
%         whoPass = cur(: , 5);
%         whoPassHistograma( counter , : ) = [ sum( whoPass == 1 ) , sum( whoPass == 2 )...
%             sum( whoPass == 3 )] / length( whoPass ) ;
%         
%         whenPassed = cur(: , 6);
%         vec = hist( whenPassed , 1 : 3)/ length( whenPassed );
%         clustersToPassHalfOneGenderHistograma( counter , : ) = vec ;
%         
%         clustToPassHalfAll = cur( : , 3 );
%         vec = hist( clustToPassHalfAll , 1 : 3)/ length( clustToPassHalfAll );
%         clustersToPassHalfAllHistogram( counter , : ) = vec ;
%         
%         counter = counter + 1;
%     end
%     % typical
%     figure; hold on;
%     % to we can see
%     typical( typical == 1 ) = 0.99;
%     typical2Gender( typical2Gender == 1 ) = 0.99;
%     plot( numberOfCluster , typical , 'k' , 'LineWidth' , 2);
%     plot( numberOfCluster , typical2Gender , 'g' , 'LineWidth' , 2);
%     legend({'Have typical brain' , 'Have typical brain to the 2 gender'} , ...
%         'Location' , 'SouthWest');
%     title(sprintf('%s - The ratio of the partitions that have a typical brain', mString ) );
%     axis( [ 1 maxClusterNumber 0 1 ]);
%     set( gca , 'xtick' , [ 1 : maxClusterNumber ] );
%     
%     name = fullfile( setName , 'images' , 'clustering' , ...
%         sprintf('typicalBrainRatio_%s.png' , mString ) ) ;
%     if SAVE
%         screen2png( name );
%     end
%     % who Pass First
%     figure; hold on;
%     bar( numberOfCluster , whoPassHistograma );
%     set( gca, 'xtick' , [ 1 numberOfCluster] );
%     legend( {'Males pass' , 'Females pass' , 'Same time' } );
%     title(sprintf( '%s- who from the gender pass the half in less clusters', mString) );
%     
%     name = fullfile( setName , 'images' , 'clustering' , ...
%         sprintf('passTheHalf_%s.png' , mString ) ) ;
%     if SAVE
%         screen2png( name );
%     end
%     % histogram of in how many number of clusters we pass the half.
%     figure; hold on;
%     h = bar( numberOfCluster , clustersToPassHalfOneGenderHistograma );
%     set( h(1) ,'Facecolor' , 'y' );
%     set( h(2) ,'Facecolor' , 'g' );
%     set( h(3) ,'Facecolor' , 'c' );
%     set( gca, 'xtick' , [ 1 numberOfCluster] );
%     legend( {'1 cluster' , '2 cluster' , '3 cluster' } );
%     title(sprintf( '%s- how many clusters its took to the first gender to pass the half' , mString ) );
%     
%     name = fullfile( setName , 'images' , 'clustering' , ...
%         sprintf('clustToPassTheHalf_%s.png' , mString ) ) ;
%     if SAVE
%         screen2png( name );
%     end
%     oneGenderPass = nan( 2 , 7 );
%     % first line man pass, second line females pass
%     for whoP = 1 : 2
%         cur = result( result(: , 5 ) == whoP , : );
%         if isempty( cur )
%             continue;
%         end
%         femalesRate = cur( : , 8 ) ; malesRate = cur( : , 7 );
%         meanFemals = mean( femalesRate );
%         minFemales = min( femalesRate );
%         maxFemales = max( femalesRate );
%         meanMales = mean( malesRate );
%         minMales = min( malesRate );
%         maxMales = max( malesRate );
%         maxDiff = max( femalesRate - malesRate );
%         oneGenderPass( whoP , : ) = [ minMales maxMales meanMales minFemales maxFemales meanFemals maxDiff];
%     end
%     
%     save( fullfile( setName , 'images' , 'clustering' , ...
%         sprintf('oneGenderPass_%s' , mString ) ) ...
%         , 'oneGenderPass');
%     
% end

%% histogram of dividing to 2

% mostTypicalyInMalesAndFemales = 0;
% 
% % next three to the small cluster
% moreMales = 0;
% moreFemales = 0;
% equal = 0;
% moreGenderInSmallClass = nan( 2 , 3 );
% hieRes = [] ;
% kmeansRes = [] ;
% for threshold = [0 , 10 , 30 ];
%     percGood = [] ;
%     for j = [ 1 , evaluationAmount + 1 ]
%         moreMales = 0;
%         moreFemales = 0;
%         equal = 0;
%         if j == evaluationAmount + 1
%             mString = 'Hierarchical';
%         else
%             mString = 'K-means';
%         end
%         for i = 1 : size( groupsIntoClustering2_10 , 1)
%             curOpt = unsupervisedResult2_10( i , 5 : end );
%             ind = find( curOpt( j : j + evaluationAmount - 1 ) == 2 , 1 );
%             if ~isempty( ind )
%                 ind = ind + j - 1;
%                 curAll = groupsIntoClustering2_10{ i , ind };
%                 s = sum( curAll , 2 ) > ( threshold / 100 * sum2( curAll ) );
%                 malePerc = curAll(: , 1 ) ./ sum( curAll , 2 );
%                 percGood = [percGood ; malePerc( s ) ];
%                 
%                 if threshold == 0
%                     % find if in the large groups there is more males and females that
%                     % the other groups
%                     s = sum( curAll , 2 );
%                     if s(1) > s(2)
%                         if all( curAll(1, : ) > curAll(2 , : ) )
%                             mostTypicalyInMalesAndFemales = mostTypicalyInMalesAndFemales + 1;
%                         end
%                         if curAll( 2 , 1 ) > curAll( 2 , 2 ) % more males in the small cluster
%                             moreMales = moreMales + 1;
%                         elseif curAll( 2 , 1 ) < curAll( 2 , 2 )
%                             moreFemales = moreFemales + 1;
%                         else
%                             equal = equal + 1;
%                         end
%                     else
%                         if all( curAll(1, : ) < curAll(2 , : ) )
%                             mostTypicalyInMalesAndFemales = mostTypicalyInMalesAndFemales + 1;
%                         end
%                         if curAll( 1 , 1 ) > curAll( 1 , 2 ) % more males in the small cluster
%                             moreMales = moreMales + 1;
%                         elseif curAll( 1 , 1 ) < curAll( 1 , 2 )
%                             moreFemales = moreFemales + 1;
%                         else
%                             equal = equal + 1;
%                         end
%                     end
%                     
%                     if j == evaluationAmount + 1 % hierarchcal
%                         [ m , indMin ] = min( sum( curAll , 2 ) );
%                         hieRes( end + 1 , : ) = [ m , curAll( indMin , : ) ];
%                     else %k-means
%                         [ m , indMax ] = max( sum( curAll , 2 ) );
%                         kmeansRes( end + 1 , : ) = [ 1 + double(curAll( indMax , 2 ) > curAll( indMax , 1 )) , ...
%                             curAll( indMax , : ) ];
%                     end
%                     
%                 end
%             end
%         end
%         if threshold == 0
%             if j == 10
%                 moreGenderInSmallClass( 1 , : ) = [ moreMales ,  moreFemales , equal];
%             else
%                 moreGenderInSmallClass( 2 , : ) = [ moreMales ,  moreFemales , equal];
%             end
%         end
%     end
%     mi = min( percGood );
%     ma = max( percGood );
%     figure; hist( percGood , [mi : 0.02 : ma ] );
%     hold on;
%     title( sprintf('The division to 2 clusters. The rate of males in each cluster with at least %d% of the brains' , threshold ) );
%     name =  fullfile( setName , 'images' , 'clustering' , ...
%         sprintf('malesRatio_divideTo2_atLeast%d.png', threshold ) ) ;
%     if SAVE
%         screen2png( name );
%     end
% end
% figure; hold on;
% bar( 1:2 , moreGenderInSmallClass / sum( moreGenderInSmallClass(1 , : ) ) );
% set( gca, 'xtick' , [ 1 2] );
% set( gca, 'xticklabel' , {'hierarchical' , 'k-means' } );
% legend( {'more males' , 'more females' , 'equal' } );
% title( sprintf('The division to 2 clusters. Which gender is dominate in the small cluster' ) );
% name = fullfile( setName , 'images' , 'clustering' , ...
%     sprintf('genderDominateInSmllCluster_divideTo2.png') );
% if SAVE
%     screen2png( name );
% end
% % embeded the result - hierarchi
% smallClusterSize = [min( hieRes(: , 1 ) ) , ...
%     max( hieRes(: , 1 ) ) , mean( hieRes(: , 1 ) ) ];
% moreMalesInSmallCluster = sum( hieRes(: , 2 ) > hieRes(: , 3 ) ) / size( hieRes , 1 );
% 
% % for kmeans
% moreMaleInLargeCluster = sum( kmeansRes(: , 1 ) == 1) / size( kmeansRes , 1 );
% malesInLargeClusterDominateByMales = [min( kmeansRes(kmeansRes(: , 1 ) == 1 , 2 ) ) , ...
%     max( kmeansRes(kmeansRes(: , 1 ) == 1 , 2 ) ) , ...
%     mean( kmeansRes(kmeansRes(: , 1 ) == 1 , 2 ) ) ];
% malesInLargeClusterDominateByFemales = [min( kmeansRes(kmeansRes(: , 1 ) == 2 , 2 ) ) , ...
%     max( kmeansRes(kmeansRes(: , 1 ) == 2 , 2 ) ) , ...
%     mean( kmeansRes(kmeansRes(: , 1 ) == 2 , 2 ) ) ];
% 
% moreFemaleInLargeCluster = sum( kmeansRes(: , 1 ) == 2) / size( kmeansRes , 1 );
% femalesInLargeClusterDominateByMales = [min( kmeansRes(kmeansRes(: , 1 ) == 1 , 3 ) ) , ...
%     max( kmeansRes(kmeansRes(: , 1 ) == 1 , 3 ) ) , ...
%     mean( kmeansRes(kmeansRes(: , 1 ) == 1 , 3 ) ) ];
% femalesInLargeClusterDominateByFemales = [min( kmeansRes(kmeansRes(: , 1 ) == 2 , 3 ) ) , ...
%     max( kmeansRes(kmeansRes(: , 1 ) == 2 , 3 ) ) , ...
%     mean( kmeansRes(kmeansRes(: , 1 ) == 2 , 3 ) ) ];


%% anomaly in hierarchical clustering- not graph

runsMethods = unsupervisedResult2_10( : , 1 );
a = allCluster2Linkage;

% convert to 1 anomaly from small groups
% len = size( a , 1 );
% res = a;
% for j = 1 : size( a , 2 )
%     c = a(: , j );
%     c = c - 1;
%     if sum(c) > 0.9 * len;
%         c = ~c;
%     elseif sum(c) > 0.1 * len
%         c = zeros( size(c));
%     end
%     res( : , j ) = c;
% end
% me = unique( runsMethods )';
% curMehtodAnomaly = nan( size( res , 1 ) , length( me ) );
% for i = me
%     curMehtodAnomaly(: , i ) = sum( res( : , runsMethods == i ) , 2 ) / sum(runsMethods == i ) > 0.1 ;
% end
% totAnomaly = sum( curMehtodAnomaly , 2 );
% 
% for i = 2 : length( me )
%     curAnomaly( i - 1 ) = sum( totAnomaly >= i  );
% end
% 
% figure; hold on
% bar( 2 : length( me ) , curAnomaly / len );
% set( gca, 'xtick' , 2 : length( me ) );
% title( sprintf('Anomaly brains in some methods. Clustering to 2 clusters by hierarchical algorithm' ) );
% name = fullfile( setName , 'images' , 'clustering' , ...
%     sprintf('anomalyBrainHierarchical2Clusters.png') ) ;
% if SAVE
%     screen2png( name );
% end%% anomaly detection

%% another process of anomaly detection
sz = 4; % size of circle in gsccater
a = ADFemaleModelResult;
a = reduceAnomaly( a );
meth = a( : , 1 );
a = a(: , [end - 1 : end ] );
figure; hold on;
x = a(: , 2); y = 1 - a(: , 1 );
plot( x , y , 'b.' )
title('Anomaly detection')
plot( [ 0 ; 1 ] , [ 0 ; 1] , 'k' );
% plot the in mean of the data
fitObject = fit(x , y , 'poly1' );
plot( fitObject )
legend('off')
axis([0 1 0 1])
xlabel('Females that classified as a females (not anomaly)')
ylabel('Males that classified as a females (not anomaly)')
name = fullfile( setName , 'images' , 'anomaly detection' , ...
    sprintf('anomalyDetection_male_model.png') ) ;
if SAVE
    screen2png( name );
end
figure; hold on;
gscatter( x , y , meth , 'bgrcmyk' , 'o' , sz)
title('Anomaly detection')
xlabel('Females that classified as a females (not anomaly)')
ylabel('Males that classified as a females (not anomaly)')
axis([0 1 0 1])
legend( reduceMethods , 'Location' , 'West');

name = fullfile( setName , 'images' , 'anomaly detection' , ...
    sprintf('anomalyDetection_male_model_per_method.png') ) ;
if SAVE
    screen2png( name );
end
a = ADMaleModelResult;
a = reduceAnomaly( a );
meth = a( : , 1 );
a = a(: , [end - 1 : end ] );

figure; hold on;
x = a(: , 1); y = 1 - a(: , 2 ) ;
plot( x , y , 'b.' )
title('Anomaly detection')
plot( [ 0 ; 1 ] , [ 0 ; 1] , 'k' );
% plot the in mean of the data
fitObject = fit(x , y , 'poly1' );
plot( fitObject )
axis([0 1 0 1])
xlabel('Males that classified as a Males (not anomaly)')
ylabel('Females that classified as a Males (not anomaly)')
legend('off')
name = fullfile( setName , 'images' , 'anomaly detection' , ...
    sprintf('anomalyDetection_female_model.png') ) ;
if SAVE
    screen2png( name );
end
figure;
gscatter( x , y , meth  , 'bgrcmyk' , 'o' , sz)
title('Anomaly detection')
xlabel('Males that classified as a Males (not anomaly)')
ylabel('Females that classified as a Males (not anomaly)')
axis([0 1 0 1])
legend( reduceMethods , 'Location' , 'West');

name = fullfile( setName , 'images' , 'anomaly detection' , ...
    sprintf('anomalyDetection_female_model_per_method.png') ) ;
if SAVE
    screen2png( name );
end
%% show "cloud" in anomaly detecion
% FIND_RUN = 0;
% % find a run
% RAND = 0;
% a = ADFemaleModelResult;
% a = reduceAnomaly( a );
% afterReducing = a;
% if FIND_RUN
%     meth = a( : , 1 );
%     a = a(: , [end - 1 : end ] );
%     figure; hold on;
%     x = a(: , 2); y = 1 - a(: , 1 );
%     plot( x , y , 'b.' )
%     title('Anomaly detection')
%     xlabel('Females that classified as a females (not anomaly)')
%     ylabel('Males that classified as a females (not anomaly)')
%     plot( [ 0 ; 1 ] , [ 0 ; 1] , 'k' );
%     % plot the in mean of the data
%     fitObject = fit(x , y , 'poly1' );
%     plot( fitObject )
%     axis([0 1 0 1])
%     
%     a = ginput( 1 );
%     dis = pdist2( a , [x , y ] );
%     [ m , ind ] = min( dis );
% else
%     % run over all the partiotions
%     [ rows ]  = unique( afterReducing(: , [ 1 3 4] ) , 'rows');
%     load (fullfile( setName , 'allDataGroupsRandomized1.mat' ) );
%     
%     for i = 1 : size( rows , 1 )
%         row = rows( i , : );
%         reduce = reduceMethods{ row(1 ) };
%         name = sprintf('data/set1 method is %s , epsilon is %s , mu is %s.mat' ,...
%             reduce , num2str(row(2)) , num2str(row(3)));
%         name = fullfile( setName , name );
%         tmp = load( name );
%         reducingData = tmp.reducingData;
%         if strcmp( reduce , 'PDME') || strcmp( reduce , 'ICPQR' )
%             reducingData = reducingData(: , 2 : end );
%         end
%         [~ , ~ , ~ , baseMatMale] = tryAnnomalyDtection( reducingData , allGroups , 1 , 1 );
%         [~ , ~ , ~ , baseFematMale] = tryAnnomalyDtection( reducingData , allGroups , 2 , 1 );
%         handle = figure('units' , 'normalized' , 'outerposition' , [0 0 1 1]);
%         hold on;
%         if size( baseMatMale , 2 ) < 2
%             continue
%         end
%         plot( baseMatMale(: , 1 ) , baseMatMale(: , 2 ) , 'b.' );
%         plot( baseFematMale(: , 1 ) , baseFematMale(: , 2 ) , 'r.' );
%         title('The spread of the model. Males (blue) and Females (red)');
%         name = fullfile( setName , 'images' , 'anomaly detection' , ...
%             sprintf('spreadOfTheModel%d.png' , i) );
%         if SAVE
%             screen2png( name );
%         end
%         pause(1)
%     end
% end

%% plot the best diff between males and femals
% load ( fullfile( setName, 'allDataGroupsRandomized1.mat' ) );
% 
% if GROUP_SIZES
%     allGroups = double( allFullSize < median( allFullSize) )  + 1;
% end
% counter = 0;
% for i = 1 : length( reduceMethods )
%     if strcmp( reduce , 'pca' ) || strcmp( reduce , 'none' )
%         epsilon = 0;
%     else
%         epsilon = EPSILONS;
%     end
%     if strcmp( reduce , 'pca' ) || strcmp( reduce , 'dm' ) || strcmp( reduce , 'none' )
%         mu = 0;
%     else
%         mu = MU;
%     end
%     for eps = epsilon
%         for curMu = mu
%             fprintf('method is %s , epsilon is %.2f , mu is %.2f\n' , reduce , eps , curMu );
%             name = sprintf('data/set1 method is %s , epsilon is %s , mu is %s.mat' , reduce , num2str(eps) , num2str(curMu));
%             name = fullfile( setName , name );
%             if exist(name , 'file' )
%                 a = load( name );
%                 reducingData = a.reducingData;
%             else
%                 reducingData = getReducingData( normData , reduce , 0 , eps , curMu );
%                 save(name , 'reducingData' );
%             end
%             if strcmp( reduce , 'PDME')
%                 reducingData = reducingData(: , 2 : end );
%             end
%             
%             diffMat = findMaxCohensD( reducingData , allGroups );
%             if size( diffMat , 2 ) < 2 
%                 continue
%             end
%             figure; hold on;
%             plot( diffMat(allGroups == 1 , 1 ) , diffMat(allGroups == 1 , 2 ) , 'b.' );
%             plot( diffMat(allGroups == 2 , 1 ) , diffMat(allGroups == 2 , 2 ) , 'r.' );
%             title('The spread of the model. Males (blue) and Females (red)');
%             counter = counter + 1;
%             name = fullfile( setName , 'images' , 'general' , ...
%                 sprintf('spreadOfTheModel%d.png' , counter) );
%             if SAVE
%                 screen2png( name );
%             end
%         end
%     end
% end
%% learn from one region
% load('learnOnRegion.mat');
%
% a = learnOnReagion;
% method = unique( a( : , 1 ) )';
% result = nan( length( method) + 1 , length( regions ) );
% for i = method
%     counter = 1;
%     for r = 1 : length( regions )
%         if strcmp( regions{r} , 'Cambridge_Buckner' ) ||
%             strcmp( regions{r} , 'Beijing_Zang' )
%             cur = a ( a(: , 1 ) == i & a( : , 5 ) == r , end - 1 : end );
%             curVal = max( min( cur , [] , 2 ) );
%             if ~isempty( curVal )
%                 result( i , counter) = curVal;
%                 counter = counter + 1;
%             end
%         end
%     end
% end
% figure; hold on;
% bar( result );
% legend( regions);
% hold on
% title('Learn from one origin and test on the others')

%% for four regions
% load learnOnFourRegion.mat % for one run
% load regionResult9Randomized.mat % for 9 randomized runs
%
% if size( regionResult , 2 ) > 8
%     % mean over all the runs
%     c = unique( regionResult( : , 1 : 6 ) , 'rows' );
%     a = nan( size( c , 1 ) , 8 );
%     for i = 1 : size( c , 1 )
%         cur = c( i , : );
%         ind = all( regionResult(: , 1 : 6 ) == repmat( cur , [ size( regionResult , 1 ) , 1] ), 2 );
%         currVals = regionResult( ind , end -1 : end );
%         curMean = mean( currVals , 1);
%         a( i , : ) = [ cur , curMean ] ;
%     end
% else
%     a = regionResult;
% end
% method = unique( a( : , 1 ) )';
% train = unique( a( : , 5 ) )';
% test = unique( a( : , 6 ) )';
% result = nan( length( method) + 2 , 11  );
% for i = method
%     counter = 1;
%     for tr = train
%         for te = mod( tr : tr + length( test ) - 1 , 3)
%             if te == 0
%                te = 3;
%             end
%             cur = a ( a(: , 1 ) == i & a( : , 5 ) == tr & a( : , 6 ) == te , end - 1 : end );
%             curVal = max( min( cur , [] , 2 ) );
%             if ~isempty( curVal )
%                 result( i , counter) = curVal;
%                 counter = counter + 1;
%             end
%         end
%         counter = counter + 1;
%     end
% end
% figure; hold on;
% h = bar( result);
% % set( h(1) ,'Facecolor' , 'r' );
% % set( h(2) ,'Facecolor' , 'g' );
% % set( h(3) ,'Facecolor' , 'b' );
% % set( h(4) ,'Facecolor' , 'c' );
% % set( h(5) ,'Facecolor' , 'r' );
% % set( h(6) ,'Facecolor' , 'g' );
% % set( h(7) ,'Facecolor' , 'b' );
% % set( h(8) ,'Facecolor' , 'c' );
% % set( h(9) ,'Facecolor' , 'r' );
% % set( h(10) ,'Facecolor' , 'g' );
% % set( h(11) ,'Facecolor' , 'b' );
% leg = cell( 0 );
% for tr = train
%     switch tr
%         case 1
%             trainName = 'israel';
%         case 2
%             trainName = 'cambridge';
%         case 3
%             trainName = 'beijing';
%     end
%     for te = mod( tr : tr + length( test ) - 1 , 3)
%         if te == 0
%             te = 3;
%         end
%         switch te
%             case 1
%                 testName = 'israel';
%             case 2
%                 testName = 'cambridge';
%             case 3
%                 testName = 'beijing';
%         end
%         name = sprintf('learn from %s, testing on %s' , trainName , testName );
%         leg{ end + 1 } = name;
%     end
%     leg{ end + 1 } = '';
% end
% legend( leg);
% hold on
% set( gca, 'xtick' , 1 : 5 );
% set( gca, 'xticklabel' , {'none' , 'PCA' , 'DM' , 'IDM' , 'ICPQR'} );
%
% title('Learn on one origin and test on other origin');

%% find if in linkage the anomaly is every time same anomaly
% load allDataGroupsRandomized9.mat
% load unsupervisedRandomize9.mat
% runsMethods = unsupervisedResult2_10( : , 1 );
% a = allCluster2Linkage;
%
% % convert to 1 anomaly from small groups
% len = size( a , 1 );
% res = a;
% for j = 1 : size( a , 2 )
%     c = a(: , j );
%     c = c - 1;
%     if sum(c) > 0.9 * len;
%         c = ~c;
%     elseif sum(c) > 0.1 * len
%         c = zeros( size(c));
%     end
%     res( : , j ) = c;
% end
% me = unique( runsMethods )';
% % find who is normalize in all the methods
% anomalyBrains = sum( res , 2 );
% normalyInAllMethods = sum( anomalyBrains == 0 );
%
% % for males
% ind = find( allGroups == 1 );
% figure('units' , 'normalized' , 'outerposition' , [0 0 1 1]);
% hold on;
% colors = 'bgrcmyk';
% for i = me
%     curAno = res( ind , runsMethods == i );
%     curValues = sum( curAno , 2 ) / sum( runsMethods == i );
%     plot( curValues , [colors(i), '.' ] )
% end
% legend('none' , 'PCA' , 'diffusion map' , 'isometric diffusion map' ,'ICPQR'  );
% title('Exceptionals brains from males');
%
% % for females
% ind = find( allGroups == 2 );
% figure('units' , 'normalized' , 'outerposition' , [0 0 1 1]);
% hold on;
% colors = 'bgrcmyk';
% for i = me
%     curAno = res( ind , runsMethods == i );
%     curValues = sum( curAno , 2 ) / sum( runsMethods == i );
%     plot( curValues , [colors(i), '.' ] )
% end
% legend('none' , 'PCA' , 'diffusion map' , 'isometric diffusion map' ,'ICPQR'  );
% title('Exceptionals brains from females');

%% example the difference between the hierarchical and k means

% RAND = 0;
% a = ADFemaleModelResult;
% a = reduceAnomaly( a );
% afterReducing = a;
% 
% % run over all the partiotions
% [ rows ]  = unique( afterReducing(: , [ 1 3 4] ) , 'rows');
% load allDataGroupsRandomized1.mat
% 
% for i = 1 : size( rows , 1 )
%     row = rows( i , : );
%     reduce = reduceMethods{ row(1 ) };
%     name = sprintf('data/set1 method is %s , epsilon is %s , mu is %s.mat' ,...
%         reduce , num2str(row(2)) , num2str(row(3)));
%     name = fullfile( setName , name );
%     tmp = load( name );
%     reducingData = tmp.reducingData;
%     
%     X = reducingData(: , 1:2);
%     if strcmp( reduce , 'PDME' )
%         X = reducingData( : , 2 : 3 );
%     end
%     opts = statset('Display','final');
%     [idx,ctrs] = kmeans(X,2,'Distance','city',...
%         'Replicates',5,'Options',opts);
%     figure()
%     plot(X(idx==1,1),X(idx==1,2),'y.','MarkerSize',12)
%     hold on
%     plot(X(idx==2,1),X(idx==2,2),'g.','MarkerSize',12)
%     plot(ctrs(:,1),ctrs(:,2),'kx',...
%         'MarkerSize',12,'LineWidth',2)
%     plot(ctrs(:,1),ctrs(:,2),'ko',...
%         'MarkerSize',12,'LineWidth',2)
%     legend({'Cluster 1','Cluster 2','Centroids'} , 'Location' , 'SouthEast')
%     title('K-means clustering' );
%     name = fullfile( setName , 'images' , 'example' , ...
%         sprintf('k-meansClustering%d.png' , i ) );
%     if SAVE
%         screen2png( name );
%     end    
%     figure; hold on;
%     plot(X(allGroups==1,1),X(allGroups==1,2),'b.' , 'MarkerSize',12)
%     hold on
%     plot(X(allGroups==2,1),X(allGroups==2,2),'r.' , 'MarkerSize',12)
%     legend({'males','femals','Centroids'} , 'Location' , 'SouthEast');
%     title('Divide to males and females' );
%     name = fullfile( setName , 'images' , 'example' , ...
%         sprintf('divideToMalesAndFemales%d.png' , i) );
%     if SAVE
%         screen2png( name );
%     end    
%     clustTree = linkage(X,'average' , 'euclidean');
%     clusters = cluster(clustTree,'criterion','distance','maxclust',2);
%     
%     figure;
%     plot(X(clusters==1,1),X(clusters==1,2),'y.','MarkerSize',12)
%     hold on
%     plot(X(clusters==2,1),X(clusters==2,2),'g.','MarkerSize',12)
%     legend({'Cluster 1','Cluster 2'} , 'Location' , 'SouthEast')
%     title('Hierarchical clustering' );
%     name = fullfile( setName , 'images' , 'example' , ...
%         sprintf('hierarchicalClustering%d.png' , i' ) );
%     if SAVE
%         screen2png( name );
%     end
% end


%% find exceptional in anomaly detection
% load allDataGroupsRandomized9.mat
% load anomalyDetectionRandomize9.mat
%
% % from males model
% runMethods = ADMaleModelResult(: , 1 );
% me = unique( runsMethods )';
% for males
% ind = find( ~isnan( MaleTotError(: , 1 ) ) & allGroups == 1 );
% figure('units' , 'normalized' , 'outerposition' , [0 0 1 1]);
% hold on;
% colors = 'bgrcmyk';
% for i = me
%     curAno = MaleTotError ( ind , runsMethods == i );
%     curValues = sum( curAno , 2 ) / sum( runsMethods == i );
%     plot( curValues , [colors(i), '.' ] )
% end
% legend('none' , 'PCA' , 'diffusion map' , 'isometric diffusion map' ,'ICPQR'  );
% title('Exceptionals brains from males, The model was build from male');
%
% for females
% ind = find( ~isnan( MaleTotError(: , 1 ) ) & allGroups == 2 );
% figure('units' , 'normalized' , 'outerposition' , [0 0 1 1]);
% hold on;
% colors = 'bgrcmyk';
% for i = me
%     curAno = MaleTotError ( ind , runsMethods == i );
%     curValues = sum( curAno , 2 ) / sum( runsMethods == i );
%     plot( curValues , [colors(i), '.' ] )
% end
% legend('none' , 'PCA' , 'diffusion map' , 'isometric diffusion map' ,'ICPQR'  );
% title('Exceptionals brains from females , The model was build from male');
%
%
% from females model
% runMethods = ADFemaleModelResult (: , 1 );
% me = unique( runsMethods )';
% for males
% ind = find( ~isnan( FemaleTotError(: , 1 ) ) & allGroups == 1 );
% figure('units' , 'normalized' , 'outerposition' , [0 0 1 1]);
% hold on;
% colors = 'bgrcmyk';
% for i = me
%     curAno = FemaleTotError ( ind , runsMethods == i );
%     curValues = sum( curAno , 2 ) / sum( runsMethods == i );
%     plot( curValues , [colors(i), '.' ] )
% end
% legend('none' , 'PCA' , 'diffusion map' , 'isometric diffusion map' ,'ICPQR'  );
% title('Exceptionals brains from males, The model was build from females');
%
% for females
% ind = find( ~isnan( FemaleTotError(: , 1 ) ) & allGroups == 2 );
% figure('units' , 'normalized' , 'outerposition' , [0 0 1 1]);
% hold on;
% colors = 'bgrcmyk';
% for i = me
%     curAno = FemaleTotError ( ind , runsMethods == i );
%     curValues = sum( curAno , 2 ) / sum( runsMethods == i );
%     plot( curValues , [colors(i), '.' ] )
% end
% legend('none' , 'PCA' , 'diffusion map' , 'isometric diffusion map' ,'ICPQR'  );
% title('Exceptionals brains from females , The model was build from females');
%

