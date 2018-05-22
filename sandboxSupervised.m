global SAVE
SAVE = 1;

setName1 = 'GSP_VBM';
colors = [ 0 0 1; 1 0 0 ; 0 1 0 ; 1 0 1 ] ;

dataSets = {'GSP_VBM','israel', 'beijing','cambridge'};
types = '+oooooo';
result = [] ;
res2excel = [];
for filterAges = [0 1]
    figure( 'position' , [0 0 900 900] );
    hold on;
    for k =1 : length(dataSets )
        setName2 = dataSets{k};
        load( fullfile( setName1 , sprintf( '%s_supervisedResult_filterAges_%d.mat' , setName2 , AGES_FILTER ) ) , 'kfoldResult' , 'reduceMethods' , 'methods');
        resultMat = kfoldResult;
        if isempty( resultMat )
            continue
        end
        %     mean over all the randomized value
        for mInd = 1: length( methods )
            m = methods{ mInd };
            c = unique( resultMat( : , 1 ) , 'rows' );
            a = nan( size( c , 1 ) , 3 );
            for i = 1 : size( c , 1 )
                cur = c( i , : );
                ind = all( resultMat(: , 1  ) == ...
                    repmat( cur , [ size( resultMat , 1 ) , 1] ), 2 );
                curVals = resultMat( ind , 4 + [ 2 * mInd - 1  2 * mInd ] );
                [ ~ , ind ] = max( mean( curVals , 2 ) );
                curMean = curVals( ind , : );
                a( i , : ) = [ cur , curMean ] ;
                originalResult = a ;
                scatter( a(i , 3) , a(i , 2 ) , 150 ,types(i) ,'MarkerEdgeColor',colors(k, : ) ,'LineWidth', 6);
            end
            res2excel = [ res2excel , a(: , [2 3] )];
        end
    end
    axis([0 1 0 1])
    set(gca,'FontSize',30);
    if filterAges
        tit = sprintf('Age: 18-35');
    else
        tit = sprintf('Age: All');
    end
    title(tit);
    xlabel('Female successful classification rate')
    ylabel('Male successful classification rate')
    if filterAges
        screen2png( fullfile( '' , 'supervisedFilter.png'));
    else
        screen2png( fullfile( '' , 'supervisedNoFilter.png'));
    end
end

b = res2excel(: , [ 2 8 6 4 1 7 5 3 ]);
xlswrite('supervisedExcelAgesFilter.xlsx', b , 'supervised learning' ,'B2');
xlswrite('supervisedExcelAgesFilter.xlsx', reduceMethods' , 'supervised learning' ,'a2');
xlswrite('supervisedExcelAgesFilter.xlsx', [ dataSets( [ 1 4 3 2] ) dataSets( [ 1 4 3 2] )], 'SL' ,'B1');

%% calculate the predicate
for AGES_FILTER = [ 0 , 1]
    leg1 = cell( 0 );
    leg3 = cell( 0 );
    same_predict = [];selfCorrect = [];gspCorrect = [];
    sets = {'israel', 'beijing','cambridge'};
    for indSet = 1 : length( sets )
        testSet = sets{indSet};
        %% load the classification result
        % when train on GSP
        trainSet = 'GSP_VBM';
        load( fullfile( 'GSP_VBM' , sprintf( 'train_%s_test_%s_classification_testing_agesFilter_%d.mat' , trainSet , testSet , AGES_FILTER) ) , 'classificationResult' , 'reduceMethods' , 'methods' , 'testGroups', 'models');
        resGSP = [];
        for b = unique( classificationResult( 1, : ) )
            indices = find ( classificationResult( 1 , :) == b );
            [ maxScore , ind ] = max( classificationResult( 5 , indices) ); %score row
            resGSP = [ resGSP , classificationResult( 6 : end , indices( ind( 1) ) ) ];
        end
        % when train on the current test set (with k-fold, of course)
        trainSet = testSet;
        load( fullfile( 'GSP_VBM' , sprintf( 'train_%s_test_%s_classification_testing_agesFilter_%d.mat' , trainSet , testSet , AGES_FILTER) ) , 'classificationResult' , 'reduceMethods' , 'methods' , 'testGroups', 'models');
        resSelf = [];
        for b = unique( classificationResult( 1, : ) )
            indices = find ( classificationResult( 1 , :) == b );
            [ maxScore , ind ] = max( classificationResult( 5 , indices) ); %score row
            resSelf = [ resSelf , classificationResult( 6 : end , indices( ind( 1) ) ) ];
        end
        %% predicate 1
        same_predict(indSet , : ) = sum( resSelf == resGSP ) / size( resSelf , 1 );
        
        femaleSelf_correct = sum( resSelf == 2 & repmat( testGroups, [ 1 , size( resSelf , 2 ) ]) == 2)...
            / sum( testGroups == 2);
        maleSelf_correct = sum( resSelf == 1 & repmat( testGroups, [ 1 , size( resSelf , 2 ) ]) == 1)...
            / sum( testGroups == 1);
        femaleGSP_correct = sum( resGSP == 2 & repmat( testGroups, [ 1 , size( resSelf , 2 ) ]) == 2)...
            / sum( testGroups == 2);
        maleGSP_correct = sum( resGSP == 1 & repmat( testGroups, [ 1 , size( resSelf , 2 ) ]) == 1)...
            / sum( testGroups == 1);
        % if the two models are fully correlated
        correlate(indSet , : ) = mean( [ 1 - ( abs( maleSelf_correct - maleGSP_correct ) )   ...
            ; 1 - ( abs( femaleSelf_correct - femaleGSP_correct ) ) ] );
        % if the two models are absolutly independent
        independent(indSet , : ) = mean( [ (maleSelf_correct .* maleGSP_correct + (1- maleSelf_correct) .* (1 - maleGSP_correct)) ...
            ; (femaleSelf_correct .* femaleGSP_correct + (1- femaleSelf_correct) .* (1 - femaleGSP_correct)) ] );
        
        selfCorrect(indSet , : ) = sum(resSelf == repmat( testGroups, [ 1 , size( resSelf , 2 ) ])) / length( testGroups );
        gspCorrect(indSet , : ) = sum(resGSP == repmat( testGroups, [ 1 , size( resGSP , 2 ) ])) / length( testGroups );
        
        
    end
    
    
    %% write Excel
    if AGES_FILTER
        sheet = 'AGES_FILTER';
    else
        sheet = 'ALL_AGES';
    end
    xlswrite('Predicate_tree_bager.xlsx', [ same_predict' , correlate' , independent'] , sheet ,'B3');
    xlswrite('Predicate_tree_bager.xlsx', reduceMethods([1:3,5:7])' , sheet ,'A3');
    xlswrite('Predicate_tree_bager.xlsx', [ dataSets( [ 2 3 4] ) dataSets( [ 2 3 4] )  dataSets( [ 2 3 4] )], sheet ,'B2');
    xlswrite('Predicate_tree_bager.xlsx', {'same', 'same', 'same' , 'correlate' , 'correlate' , 'correlate' ...
        'independent' , 'independent' , 'independent'}, sheet ,'B1');
    
    xlswrite('Predicate_tree_bager.xlsx', [ selfCorrect' , gspCorrect'] , sheet ,'B12');
    xlswrite('Predicate_tree_bager.xlsx', reduceMethods([1:3,5:7])' , sheet ,'A12');
    xlswrite('Predicate_tree_bager.xlsx', [ dataSets( [ 2 3 4] ) dataSets( [ 2 3 4] ) ], sheet ,'B11');
    xlswrite('Predicate_tree_bager.xlsx', {'self model', 'self model', 'self model' ,...
        'gsp model' , 'gsp model' , 'gsp model' ...
        }, sheet ,'B10');
end
