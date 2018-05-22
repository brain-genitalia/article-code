global GROUP_SIZES 

SAVE =0;
if ~exist('setName' , 'var' )
    setName = 'GSP_VBM';
end
%% load the file
if GROUP_SIZES
    name = 'unsupervisedResult_group_size';
else
    name = 'unsupervisedResult';
end
load( fullfile( setName , name ));

%% plot to excel cahnce of male/male F/F M/F to be in one cluster
g = allClusterComposition;
numberOfCLusters = 3:10;
colsForalgo = size( g , 2 ) / 2;
reduceM = reduceMethods;
chance_to_be_in_same_clustaer = cell(0) ;
figure('outerposition' , [0 0 900 900]); hold on;
colors = [ 0.5 0.5 1; 1 0 0; 0 1 0 ; 0 0 1 ; 1 0.5 0 ; 1 0 1; 0 1 1 ; 0 0 0 ; 0.5 0.5 0.5 ];
zura = 'ds';
legVal = cell( 0 );

SPLIT_BY_BRAIN_SIZE = 0;

csv_table = [];
for numOfClusters = numberOfCLusters
    methodUniq = unique( unsupervisedResult2_10(: , 1 ) )';
    curPlotX = [];
    curPlotY = [];
    group_size = [] ; large_part_in_group_ratio = [];
    % iteration over the clustering methods
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
            % get all the partition of this dimensionality reduction
            % method and fint the best partition
            relevant_rows = find( unsupervisedResult2_10(: , 1) == i);
            curComposition = g( relevant_rows , colsForalgo * (clMethod - 1 ) + numOfClusters - 1 );
            finalGrade = 0;
            win = [];
            win_ind = [];
            for com = 1 : length( curComposition )                
                cur = curComposition{ com };
                curPerc = cur / (sum2( cur ) /2);
                % the grade is multiply of the cluster size by the
                % composition of this cluster
                grade = mean( sum( cur , 2 ) / sum2( cur) .* abs ( curPerc(: , 1 ) - curPerc(: , 2 ) ) );
                if finalGrade < grade
                    win = cur;
                    winPerc = curPerc;
                    grade = finalGrade;
                    win_ind = com;
                end
            end           
            cur = win;
            if SPLIT_BY_BRAIN_SIZE
                % create composition 
                is_larger = load( fullfile( setName , 'is_large_than_median' ) );
                is_larger = is_larger.is_large_than_median_result;
                cur_clust = allClust_2_10{relevant_rows(win_ind)};
                % find the relevant column
                cur_clust = cur_clust( : , numOfClusters - 1 + (clMethod - 1 ) * 9 );
                cur = [];
                for p = 1 : numOfClusters
                    cur = [cur ; sum(cur_clust == p & is_larger) , sum(cur_clust == p & ~is_larger)];
                end
            end
            M = cur(: , 1 );
            F = cur(: , 2 );
            
            large_part_in_group_ratio =[large_part_in_group_ratio ; max( cur , [] , 2 ) ./ sum( cur , 2 ) ] ;
            group_size = [group_size ; sum( cur , 2 )];
            
            % create table of all the information about the clustering
            Sizes = sum( cur , 2 );% / sum2( cur )  ;
            csv_table = [ csv_table ; 
                repmat( [numOfClusters , clMethod , i ] , numOfClusters , 1) , Sizes , M , F ];
            
            % calculate the probability of two gender to be in same cluster
            curPerc = winPerc;
            m = curPerc( : , 1 );
            f = curPerc( : , 2 );
            MM(counter ) = sum( m .* m );
            FF(counter ) = sum( f .* f );
            MF(counter ) = sum( m .* f );
        end 
        chance_to_be_in_same_clustaer =[ chance_to_be_in_same_clustaer , ...
            [ { sprintf('%.3f (%.4f)', mean( MF) , std( MF)) } ;...
            { sprintf('%.3f (%.4f)', mean( FF) , std( FF) )} ; ...
            { sprintf('%.3f (%.4f)', mean( MM) , std( MM) )} ] ]; 

    end    
    plot( group_size , large_part_in_group_ratio, 'LineStyle' , 'none', ...
                'Color' , colors( numOfClusters - min(numberOfCLusters) + 1 , : ), 'Marker',  'o' , 'MarkerSize' , 8)
           
end
ylim( [ 0.5 1] )
set( gca , 'FontSize', 30 )
title( setName );

xlabel('Number of participants in the cluster')
ylabel('Sex disparity')
if SPLIT_BY_BRAIN_SIZE
    name = sprintf('%s_prop_brain_size.png' , setName );
    ylabel('Size disparity')
else
    name = sprintf('%s_prop.png' , setName );
end
name = fullfile('' , name);
disp(setName)
