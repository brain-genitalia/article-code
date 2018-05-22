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

%% clustering - 2 clusters

all_clustaer_compositions = allClusterComposition(:,[1 , 10]);

%% choose best clusters for dictionaries
methodUniq = unique( unsupervisedResult2_10(: , 1 ) )';
all_clustaer_compositions_best = {};
for clMethod = 1 : 2
    counter = 0;
    for i = methodUniq
        counter = counter + 1;
        % get all the partition of this dimensionality reduction
        % method and fint the best partition
        relevant_rows = find( unsupervisedResult2_10(: , 1) == i);
        curComposition = all_clustaer_compositions( relevant_rows , clMethod  );
        best_grade = 0;
        win = [];
        for com = 1 : length( curComposition )
            cur = curComposition{ com };
            grade =  abs( cur( 1 , 1 ) / sum( cur(1 , : ) ) - ...
                cur( 2 , 1 ) / sum( cur(2 , : ) ) );
            if best_grade < grade
                win = cur;
                grade = best_grade;
            end
        end
        cur = win;
        all_clustaer_compositions_best{counter , clMethod} = cur;
    end
end
all_clustaer_compositions = all_clustaer_compositions_best;
%% figure of dividing - show the composition
figure('outerposition' , [0 0 900 900]); hold on;
colors = [ 1 0 0; 0 1 0 ; 0 0 1 ; 1 0 1; 0 1 1 ; 0 0 0 ];
zura = 'ds';
legVal = cell( 0 );

genderDiff = nan(size(all_clustaer_compositions));
for m = 1 : length( Methods_unsupervised )
    x = [] ; y = [] ;
    for i = 1 : size( all_clustaer_compositions , 1 )
        cur = all_clustaer_compositions{ i , m };
        if sum2( cur) == 0
            continue
        end
        [~ , largeCluster] = max( sum( cur , 2 ) );
        smallCluster = 3 - largeCluster;
        maleLarge = cur( largeCluster , 1 );
        femaleLarge = cur( largeCluster , 2 );
        allMale = sum( cur(: , 1 ) );
        allFemale = sum( cur(: , 2 ) );
        x1 = femaleLarge / allFemale;
        y1 = maleLarge / allMale;
        genderDiff( i , m ) = abs( x1 - y1 );
        scatter( x1 , y1 , 300 ,zura(m) ,'MarkerFaceColor',colors(i, : ));
    end
end
axis( [0 1 0 1 ])

set(gca,'FontSize',30);
title(setName,'FontSize', 30);
xlabel('Ratio of females in the large cluster','FontSize', 20);
ylabel('Ratio of males in the large cluster','FontSize', 20);
name =  fullfile( '' , 'The composition of the 2 clusters_my.png' );
screen2png( name );

%% calc the probabilty to be in same cluster
ff = nan( size(all_clustaer_compositions) );
fm = nan( size(all_clustaer_compositions)  );
mm = nan( size(all_clustaer_compositions)  );
for i = 1 : numel(all_clustaer_compositions)
    cur = all_clustaer_compositions{i};
    f1 = cur( 1 , 2 ) / sum( cur(: , 2 ) );
    f2 = cur( 2 , 2 ) / sum( cur(: , 2 ) );
    m1 = cur( 1 , 1 ) / sum( cur(: , 1 ) );
    m2 = cur( 2 , 1 ) / sum( cur(: , 1 ) );
    ff(i) = f1 * f1 + f2 * f2;
    fm(i) = f1 * m1 + f2 * m2;
    mm(i) = m1 * m1 + m2 * m2;
end
% for all the partitions
ff = ff * 100; fm = fm * 100; mm = mm * 100;
fprintf('setName %s - All\n' , setName );
maxInd = find( genderDiff == max2( genderDiff) , 1);
fprintf('Max values: FM: %.1f  FF: %.1f  MM: %.1f\n' , fm( maxInd) , ff( maxInd) , mm( maxInd) );
fprintf('Mean values: FM: %.1f  FF: %.1f  MM: %.1f\n' , mean( fm(:) ) , mean( ff(:)) , mean( mm(:) ) );

% for k means
kmeans = [ ff(: , 1 ) , mm(: , 1 ) , fm(: , 1 ) ];
meanKmeans = mean( kmeans );
[~ , indKmeans ] = max( genderDiff(: , 1 ) );
maxDiffKmeans = kmeans(indKmeans , : );
fprintf('setName %s - Kmeans\n' , setName );
fprintf('Max values: FM: %.1f  FF: %.1f  MM: %.1f\n' , maxDiffKmeans( [3 , 1 , 2] ) );
fprintf('Mean values: FM: %.1f  FF: %.1f  MM: %.1f\n' , meanKmeans( [3 , 1 , 2] )  );

% for hierarchy
hierarchy = [ ff(: , 2 ) , mm(: , 2 ) , fm(: , 2 ) ];
meanhierarchy = mean( hierarchy );
[~ , indhierarchy ] = max( genderDiff(: , 2 ) );
maxDiffhierarchy = hierarchy(indhierarchy , : );
fprintf('setName %s - Hierarchy\n' , setName );
fprintf('Max values: FM: %.1f  FF: %.1f  MM: %.1f\n' , maxDiffhierarchy( [3 , 1 ,2] ) );
fprintf('Mean values: FM: %.1f  FF: %.1f  MM: %.1f\n' , meanhierarchy( [3 , 1 , 2] )  );

%% anomaly detection

figure('outerposition' , [0 0 900 900]); hold on;
colors = [ 1 0 0; 0 1 0 ; 0 0 1 ; 1 0.5 0 ; 1 0 1; 0 1 1 ; 0 0 0 ];
zura = 'ds';
bigThr = 80;
smallThr = 39;

sz = 4; % size of circle in gsccater
a = ADFemaleModelResult;
a = a( a( : , 6 ) > smallThr & a( : , 6 ) < bigThr, [end - 1 : end ] );
x1 = a(: , 2); y1 = 1 - a(: , 1 );

a = ADMaleModelResult;
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
legend( legVal );


fprintf( 'setName - %s\n' , setName);
fprintf( 'From males %.4f\n' , mean( x2 ./ y2 ));
fprintf( 'From females %.4f\n' , mean( x1 ./  y1 ));

title([ 'Anomaly detection - ' , setName ])

xlabel('Ratio of males classified as normal')
ylabel('Ratio of females classified as normal')

plot( [ 0 ; 1 ] , [ 0 ; 1] , 'k' , 'LineWidth' , 0.2);
set(gca,'FontSize',30);

name = fullfile( setName , imagesDir , 'anomaly detection' , ...
    sprintf('anomalyDetection_my.png') ) ;
if SAVE
    screen2png( name );
end

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

