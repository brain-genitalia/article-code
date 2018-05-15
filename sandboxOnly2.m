global times GROUP_SIZES
global Methods_unsupervised
times = 1;
global FEATURE_SELECTION
if isempty( FEATURE_SELECTION )
    FEATURE_SELECTION = 0;
end
global chanceTable
evaluationAmount = 1;
SAVE = 0;
leg = 0;
if ~exist('setName' , 'var' )
        setName = 'GSP_volume_divide_power';
end


%% unsupervised
if GROUP_SIZES
    imagesDir = 'imagesVolume';
    load( fullfile( setName , 'unsupervisedResultAutoEpsilonGroupsSizes' ));
else
    imagesDir = 'imagesNew';
    try
        load( fullfile( setName , 'unsupervisedResultAutoEpsilon' ));
    catch
        try
            load( fullfile( setName , 'unsupervisedResultAutoEpsilon_May18'));
        catch
            load( fullfile( setName , 'unsupervisedResultAutoEpsilon') );
        end
    end
end
%% plot groups for final number of classes
% if isempty(groupsIntoClustering2)
%     groupsIntoClustering2 = groupsIntoClustering2_10(: , 1:2);
% end
% g = groupsIntoClustering2;
% for i = 1 : size( g , 1 )
%     for j = 1 : size( g , 2 )
%         cur = g{ i , j };
%         if size( cur , 1 ) == 1
%             cur = [ cur; 0 0 ];
%         end
%         cur( isnan( cur) ) = 0;
%         g{ i , j } = cur;
%     end
% end
% %% choose best clusters for dictionaries
% newG = cell( 0 );
% newResult = [];
% winnerIndices = [];
% for j = 1 : size( g , 2 )
%     curAlgo = g(: , j );
%     methodUniq = unique( unsupervisedResult2(: , 1 ) )';
%     for in = methodUniq
%         x = [] ; y = [] ;
%         grade = 0 ;
%         win = [];
%         for i = find( unsupervisedResult2(: , 1 ) == in )'
%             cur = curAlgo{ i };
%             curGrade = abs( cur( 1 , 1 ) / sum( cur(1 , : ) ) - ...
%                 cur( 2 , 1 ) / sum( cur(2 , : ) ) );
%             if curGrade > grade
%                 grade = curGrade;
%                 win = i;
%             end
%         end
%         winnerIndices( j , in ) = win;
%         newG{ in , j } = g{ win , j };
%         newResult( in , : ) = unsupervisedResult2( win , : );
%     end
% end
% g = newG;


%% figure of dividing - show the composition
figure('outerposition' , [0 0 900 900]); hold on;
colors = [ 1 0 0; 0 1 0 ; 0 0 1 ; 1 0.5 0 ; 1 0 1; 0 1 1 ; 0 0 0 ];
zura = 'ds';
legVal = cell( 0 );

genderDiff = [];
temp = [];
for m = 1 : length( Methods_unsupervised );
    x = [] ; y = [] ;
    for i = 1 : size( g , 1 )
        if i == 4 && ~strcmp( setName , 'monkeys' ) && ~strcmp( setName , 'Car_Ris')
            continue
        end
        cur = g{ i , m };
        if sum2( cur) == 0
            continue
        end
        [~ , largeCluster] = max( sum( cur , 2 ) );
        smallCluster = 3 - largeCluster;
        maleLarge = cur( largeCluster , 1 );
        femaleLarge = cur( largeCluster , 2 );
        maleSmall = cur( smallCluster , 1 );
        femaleSmall = cur( smallCluster , 2 );
        allMale = sum( cur(: , 1 ) );
        allFemale = sum( cur(: , 2 ) );
        x1 = femaleLarge / allFemale; y1 = maleLarge / allMale;
        %         x2 = (-1) * maleSmall / allMale ; y2 = (-1) * femaleSmall / allFemale ;
        genderDiff( i , m ) = abs( x1 - y1 );
        temp = [ temp ; x1 , y1 , abs( x1 -y1) ];
%         x = [ x ; x1  ];
%         y = [ y ; y1  ];
        scatter( x1 , y1 , 300 ,zura(m) ,'MarkerFaceColor',colors(i, : ));
        if strcmp( reduceMethods{i} , 'PDME')
            reduceMethods{i} = 'IDM';
        end
        legVal = [legVal , sprintf('%s - %s', reduceMethods{i} , Methods_unsupervised{m})] ;
    end
%     [xy,~,idx] = unique([ x , y] , 'rows');
%     sz = accumarray(idx(:),1);
% %     scatter( xy(: , 1 ) , xy(: , 2 ) , 20*sz ,zura(m) ,'MarkerEdgeColor','k');
%     scatter( xy(: , 1 ) , xy(: , 2 ) , 20*sz ,'c' ,'MarkerEdgeColor',colors(m));
end
axis( [0 1 0 1 ])

% legend( legVal , 'Location' , 'SouthWest' );
% set(gca,'FontSize',30);
% legend( Methods_unsupervised , 'Location' , 'SouthWest');
title(setName,'FontSize', 30);
%         xlabel('Ratio of small brains in the large cluster','FontSize', 20);
%         ylabel('Ratio of large brains in the large cluster','FontSize', 20);
xlabel('Ratio of females in the large cluster','FontSize', 20);
ylabel('Ratio of males in the large cluster','FontSize', 20);
genderDiff( 4, : ) = [];
curG = g;
% curG(4 , : ) = [];
ff = nan( size(curG) );
fm = nan( size(curG)  );
mm = nan( size(curG)  );
for i = 1 : numel(curG)
    
    cur = curG{i};
    f1 = cur( 1 , 2 ) / sum( cur(: , 2 ) );
    f2 = cur( 2 , 2 ) / sum( cur(: , 2 ) );
    m1 = cur( 1 , 1 ) / sum( cur(: , 1 ) );
    m2 = cur( 2 , 1 ) / sum( cur(: , 1 ) );
    ff(i) = f1 * f1 + f2 * f2;
    fm(i) = f1 * m1 + f2 * m2;
    mm(i) = m1 * m1 + m2 * m2;
end
ff = ff * 100; fm = fm * 100; mm = mm * 100;
fprintf('setName %s - All\n' , setName );
maxInd = find( genderDiff == max2( genderDiff) , 1);
fprintf('Max values: FM: %.1f  FF: %.1f  MM: %.1f\n' , fm( maxInd) , ff( maxInd) , mm( maxInd) );
fprintf('Mean values: FM: %.1f  FF: %.1f  MM: %.1f\n' , mean( fm(:) ) , mean( ff(:)) , mean( mm(:) ) );

kmeans = [ ff(: , 1 ) , mm(: , 1 ) , fm(: , 1 ) ];
meanKmeans = mean( kmeans );

[~ , indKmeans ] = max( genderDiff(: , 1 ) );
maxDiffKmeans = kmeans(indKmeans , : );
fprintf('setName %s - Kmeans\n' , setName );
fprintf('Max values: FM: %.1f  FF: %.1f  MM: %.1f\n' , maxDiffKmeans( [3 , 1 , 2] ) );
fprintf('Mean values: FM: %.1f  FF: %.1f  MM: %.1f\n' , meanKmeans( [3 , 1 , 2] )  );
% 
% 
hierarchy = [ ff(: , 2 ) , mm(: , 2 ) , fm(: , 2 ) ];
meanhierarchy = mean( hierarchy );
[~ , indhierarchy ] = max( genderDiff(: , 2 ) );
maxDiffhierarchy = hierarchy(indhierarchy , : );
fprintf('setName %s - Hierarchy\n' , setName );
fprintf('Max values: FM: %.1f  FF: %.1f  MM: %.1f\n' , maxDiffhierarchy( [3 , 1 ,2] ) );
fprintf('Mean values: FM: %.1f  FF: %.1f  MM: %.1f\n' , meanhierarchy( [3 , 1 , 2] )  );
name =  fullfile( setName , imagesDir , 'clustering' , 'The composition of the 2 clusters_my.png' );
screen2png( name );
% % 
% % chanceTable = [ chanceTable ; meanKmeans , maxDiffKmeans , meanhierarchy , maxDiffhierarchy ];

name =  fullfile( setName , imagesDir , 'clustering' , 'The composition of the 2 clusters_my.png' );
if SAVE
    screen2png( name );
end
% 
% if ~strcmp( setName , 'monkeys' ) && ~strcmp( setName , 'Car_Ris')
%     plot( [ 0 ; 1 ] , [ 0 ; 1] , 'k' , 'LineWidth' , 0.2);
%     name =  fullfile( setName , imagesDir , 'clustering' , 'The composition of the 2 clusters (with Line)_my.png' );
%     if SAVE
%         screen2png( name );
%     end
% 
% end
% 
% % to the presenatation
% base = 'C:\Users\user\Documents\teza\article\presentation ariel\figures';
% switch setName
%     case 'monkeys'
%         title('Primates faces','FontSize', 30);
%         xlabel('Ratio of macaques in the large cluster','FontSize', 20);
%         ylabel('Ratio of capuchins in the large cluster','FontSize', 20);
%         screen2png( fullfile( base , 'monkeys_clustering.png'));
%     case 'Car_Ris'
%         title('Carother & Ries','FontSize', 30);
%         xlabel('Ratio of females in the large cluster','FontSize', 20);
%         ylabel('Ratio of males in the large cluster','FontSize', 20);
%         screen2png( fullfile( base , 'carRis_clustering.png'));
%     case 'GSP_VBM'
%         title('GSP VBM','FontSize', 30);
%         xlabel('Ratio of females in the large cluster','FontSize', 20);
%         ylabel('Ratio of males in the large cluster','FontSize', 20);
%         screen2png( fullfile( base , 'GSP_VBM_clustering.png'));
%     case 'GSP_volume'
%         if ~GROUP_SIZES
%         title('GSP volume','FontSize', 30);
%         xlabel('Ratio of females in the large cluster','FontSize', 20);
%         ylabel('Ratio of males in the large cluster','FontSize', 20);
%         screen2png( fullfile( base , 'GSP_Volume_clustering.png'));
%         else
%             title('GSP volume, brain size','FontSize', 30);
%         xlabel('Ratio of small brains in the large cluster','FontSize', 20);
%         ylabel('Ratio of large brains in the large cluster','FontSize', 20);
%         screen2png( fullfile( base , 'GSP_volume_groupsSize_clustering.png'));
%         end
%     case 'GSP_volume_divide_power'
%         title('GSP "corrected" volume','FontSize', 30);
%         xlabel('Ratio of females in the large cluster','FontSize', 20);
%         ylabel('Ratio of males in the large cluster','FontSize', 20);
%         screen2png( fullfile( base , 'GSP_volume_corrected_clustering.png'));
%     case 'GSP_thickness'
%         title('GSP thickness','FontSize', 30);
%         xlabel('Ratio of females in the large cluster','FontSize', 20);
%         ylabel('Ratio of males in the large cluster','FontSize', 20);
%         screen2png( fullfile( base , 'GSP_thickness_clustering.png'));
%     case 'connectome_VBM'
%         title('connectomes+ VBM','FontSize', 30);
%         xlabel('Ratio of females in the large cluster','FontSize', 20);
%         ylabel('Ratio of males in the large cluster','FontSize', 20);
%         screen2png( fullfile( base , 'connectome_VBM_clustering.png'));       
% end
% 



%% figure of dividing - show the composition - for each method
% for m = 1 : length( Methods_unsupervised );
%     figure;
%     hold on
%     colors = 'rgbymck';
%     methodUniq = unique( newResult(: , 1 ) )';
%     for in = methodUniq
%         x = [] ; y = [] ;
%         for i = find( newResult(: , 1 ) == in )'
%             cur = g{ i , m };
%             if sum2( cur) == 0
%                 continue
%             end
%             [~ , largeCluster] = max( sum( cur , 2 ) );
%             smallCluster = 3 - largeCluster;
%             maleLarge = cur( largeCluster , 1 );
%             femaleLarge = cur( largeCluster , 2 );
%             maleSmall = cur( smallCluster , 1 );
%             femaleSmall = cur( smallCluster , 2 );
%             allMale = sum( cur(: , 1 ) );
%             allFemale = sum( cur(: , 2 ) );
%             x1 = femaleLarge / allFemale; y1 = maleLarge / allMale;
%             %         x2 = (-1) * maleSmall / allMale ; y2 = (-1) * femaleSmall / allFemale ;
%             x = [ x ; x1  ];
%             y = [ y ; y1  ];
%         end
%         [xy,~,idx] = unique([ x , y] , 'rows');
%         sz = accumarray(idx(:),1);
%         scatter( xy(: , 1 ) , xy(: , 2 ) , 20*sz , colors( in ));
%         axis( [0 1 0 1 ])
%     end
%     legend( reduceMethods , 'Location' , 'SouthWest');
%     xlabel('The ratio of the females in the large cluster');
%     ylabel('The ratio of the males in the large cluster');
%     if FEATURE_SELECTION
%         title( sprintf('The composition of the 2 clusters for set- %s with %s algorithm feature selection' , strrep( setName, '_' , ' ' )  , Methods_unsupervised{m} ) );
%         
%     else
%         title( sprintf('The composition of the 2 clusters for set- %s with %s algorithm' , strrep( setName, '_' , ' ' )  , Methods_unsupervised{m} ) );
%     end
%     if strcmp(setName , 'GSP_volume') && GROUP_SIZES
%         title( sprintf('The composition of the 2 clustersfor set- %s with groups by brain volume with %s algorith' , strrep( setName, '_' , ' ' ) , Methods_unsupervised{m}  ) );
%     end
%     name =  fullfile( setName , imagesDir , 'clustering' , sprintf('The composition of the 2 clusters algo %s.png', Methods_unsupervised{m}) );
%     if SAVE
%         screen2png( name );
%     end
% end


%% anomaly detection
if ~isempty( ADFemaleModelResult )
    
    if strcmp( setName , 'monkeys' ) && ( leg == 1 || ~exist( 'anomalyLegend.png' , 'file' ) )
        figure('outerposition' , [0 0 900 900]); hold on;
        colors = [ 1 0 0; 0 1 0 ; 0 0 1 ; 1 0.5 0 ; 1 0 1; 0 1 1 ; 0 0 0 ];
        zura = 'ds';
        bigThr = 80;
        smallThr = 39;
        
        if ~strcmp(setName , 'monkeys') %%&& ~strcmp(setName , 'Car_Ris')
            removeDMC = 1;
        else
            removeDMC = 0;
        end
        
        sz = 4; % size of circle in gsccater
        a = ADFemaleModelResult;
        a( a(: , 1 ) == 4 , :) = []; % remove dmC
        a = a( a( : , 6 ) > smallThr & a( : , 6 ) < bigThr, [end - 1 : end ] );
        x1 = a(: , 2); y1 = 1 - a(: , 1 );
        
        a = ADMaleModelResult;
        a( a(: , 1 ) == 4 , :) = []; % remove dmC
        a = a( a( : , 6 ) > smallThr & a( : , 6 ) < bigThr, : );
        meth = a( : , 1 );
        x2 = a(: , end - 1); y2 = 1 - a(: , end ) ;
        
        legVal = cell( 0 );
        for i = unique(meth(: , 1 ) )'
            plot( y1( meth(: , 1 ) == i ) , x1( meth(: , 1 ) == i ) , ...
                'color' , colors( i , : ),'LineStyle' , 'o' , 'MarkerSize' , 12)
            plot( x2( meth(: , 1 ) == i ) , y2( meth(: , 1 ) == i ) , ...
                'Color' , colors( i , : ), 'LineStyle',  '^' , 'MarkerSize' , 12)
            legVal = [legVal , sprintf('%s - %s', 'Females model' , reduceMethods{i}) , ...
                sprintf('%s - %s', 'Males model' , reduceMethods{i}) ] ;
        end
        legend( legVal );
        screen2png( 'anomalyLegend.png' );
    end
    
    figure('outerposition' , [0 0 900 900]); hold on;
    colors = [ 1 0 0; 0 1 0 ; 0 0 1 ; 1 0.5 0 ; 1 0 1; 0 1 1 ; 0 0 0 ];
    zura = 'ds';
    bigThr = 80;
    smallThr = 39;
    
    if ~strcmp(setName , 'monkeys') %%&& ~strcmp(setName , 'Car_Ris')
        removeDMC = 1;
    else
        removeDMC = 0;
    end
    
    sz = 4; % size of circle in gsccater
    a = ADFemaleModelResult;
    a( a(: , 1 ) == 4 , :) = []; % remove dmC
    a = a( a( : , 6 ) > smallThr & a( : , 6 ) < bigThr, [end - 1 : end ] );
    x1 = a(: , 2); y1 = 1 - a(: , 1 );
    
    a = ADMaleModelResult;
    a( a(: , 1 ) == 4 , :) = []; % remove dmC
    a = a( a( : , 6 ) > smallThr & a( : , 6 ) < bigThr, : );
    meth = a( : , 1 );
    x2 = a(: , end - 1); y2 = 1 - a(: , end ) ;
    
    legVal = cell( 0 );
    for i = unique(meth(: , 1 ) )'
        plot( y1( meth(: , 1 ) == i ) , x1( meth(: , 1 ) == i ) , 'or',...
            'color' , colors( i , : ),'Marker' , 'o' , 'MarkerSize' , 8,'LineWidth' , 2)
        plot( x2( meth(: , 1 ) == i ) , y2( meth(: , 1 ) == i ) , 'or',...
            'Color' , colors( i , : ),'Marker',  '+' , 'MarkerSize' , 8,'LineWidth' , 2)
        if strcmp( reduceMethods{i} , 'PDME')
            reduceMethods{i} = 'IDM';
        end
        legVal = [legVal , sprintf('%s - %s', 'Females model' , reduceMethods{i}) , ...
            sprintf('%s - %s', 'Males model' , reduceMethods{i}) ] ;
    end
%     legend( legVal );

    
    fprintf( 'setName - %s\n' , setName);
    fprintf( 'From males %.4f\n' , mean( x2 ./ y2 ));
    fprintf( 'From females %.4f\n' , mean( x1 ./  y1 ));
    fprintf( 'From males %.4f\n' , 100 * ( mean( x2 ./ y2 ) - 1 ));
    fprintf( 'From females %.4f\n' , 100 * (mean( x1 ./  y1 ) - 1 ));

    if FEATURE_SELECTION
        title('Anomaly detection , feature selection')
    else
        title([ 'Anomaly detection - ' , setName ])
    end
    
    
    xlabel('Ratio of males classified as normal')
    ylabel('Ratio of females classified as normal')
    
    plot( [ 0 ; 1 ] , [ 0 ; 1] , 'k' , 'LineWidth' , 0.2);
    set(gca,'FontSize',30);

    name = fullfile( setName , imagesDir , 'anomaly detection' , ...
        sprintf('anomalyDetection_my.png') ) ;
    if SAVE
        screen2png( name );
    end
    
    base = 'C:\Users\user\teza\myCode\MachineLearning\brains\appendix\p1_q2';
switch setName
    case 'monkeys'
        title('Primates faces','FontSize', 30);
        xlabel('Ratio of capuchins clasifies as "normal"','FontSize', 20);
        ylabel('Ratio of macaques clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'monkeys_AD.png'));
    case 'simulated'
        title('Simulated data','FontSize', 30);
        xlabel('Ratio of #1 clasifies as "normal"','FontSize', 20);
        ylabel('Ratio of #0 clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'simulated_AD.png'));
    case 'Car_Ris'
        title('Carother & Ries','FontSize', 30);
        ylabel('Ratio of females clasifies as "normal"','FontSize', 20);
        xlabel('Ratio of males clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'carRis_AD.png'));
     case 'GSP_VBM'
        title('GSP VBM','FontSize', 30);
        ylabel('Ratio of females clasifies as "normal"','FontSize', 20);
        xlabel('Ratio of males clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'GSP_VBM_AD.png'));
    case 'GSP_volume'
        if ~GROUP_SIZES
        title('GSP volume','FontSize', 30);
        ylabel('Ratio of females clasifies as "normal"','FontSize', 20);
        xlabel('Ratio of males clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'GSP_volume_AD.png'));
        else
            title('GSP volume, brain size','FontSize', 30);
        ylabel('Ratio of small brains clasifies as "normal"','FontSize', 20);
        xlabel('Ratio of large brains clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'GSP_volume_groupsSize_AD.png'));
        end
    case 'GSP_volume_divide_power'
        title('GSP "corrected" volume','FontSize', 30);
        ylabel('Ratio of females clasifies as "normal"','FontSize', 20);
        xlabel('Ratio of males clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'GSP_volume_corrected_AD.png'));
    case 'Cortical'
        title('Cortical','FontSize', 30);
        ylabel('Ratio of females clasifies as "normal"','FontSize', 20);
        xlabel('Ratio of males clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'Cortical_AD.png'));
    case 'Cortical_corrected'
        title('Cortical_corrected','FontSize', 30);
        ylabel('Ratio of females clasifies as "normal"','FontSize', 20);
        xlabel('Ratio of males clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'Cortical_corrected_AD.png'));
    case 'connectome_VBM'
        title('connectomes+ VBM','FontSize', 30);
        ylabel('Ratio of females clasifies as "normal"','FontSize', 20);
        xlabel('Ratio of males clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'connectome_VBM_AD.png'));
    case 'GSP_thickness'
        title('GSP thickness','FontSize', 30);
        ylabel('Ratio of females clasifies as "normal"','FontSize', 20);
        xlabel('Ratio of males clasifies as "normal"','FontSize', 20);
        screen2png( fullfile( base , 'GSP_thickness_AD.png'));
        
end
end
