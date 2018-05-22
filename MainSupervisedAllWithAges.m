% 
% global methods times reduceMethods
% reduceMethods = {'none' , 'pca' , 'dm' , 'PDME' , 'ICPQR' , 'ICPQR_data'  };
% 
% MU = 10.^(-8 : 2 : 2);
% 
% methods = {'treeBager'};% optiorn to change to 'treeBager'
% times = 1;
% models = {};
% for AGES_FILTER = [ 0 , 1  ]
%     setName1 = 'GSP_VBM';
%     for setName2 = {'GSP_VBM', 'israel', 'beijing','cambridge'}
%         models = {};
%         setName2 = cell2mat( setName2 );
%         errorIndices = [];
%         kfoldResult = [] ;
%         classificationResult = [];
%         for i = 1 : length( reduceMethods )
%             reduce = reduceMethods{ i };
%             if strcmp( reduce , 'pca' ) || strcmp( reduce , 'dm' ) || strcmp( reduce , 'none' )
%                 mu = 0;
%             else
%                 mu = MU;
%             end
%             a = load( fullfile( setName1 ,'allDataGroupsRandomized1.mat' ) );
%             b = load( fullfile( setName2 ,'allDataGroupsRandomized1.mat' ) );
%             beforeZscore = [a.allData ; b.allData ];
%             gspData = a.allData; otherData = b.allData;
%             gspAges = a.allAges; otherAges = b.allAges;
%             gspGroups = a.allGroups; otherGroups = b.allGroups;
%             disp(setName2)
%             disp(length(otherGroups))
%             
%             if AGES_FILTER
%                 indices = otherAges >= min( gspAges ) & ...
%                     otherAges <= max( gspAges );
%                 otherData = otherData( indices , : );
%                 otherGroups = otherGroups( indices );
%             end
%             fullData =[ zscore( gspData ) ; zscore( otherData ) ];
%             fullAges = [gspAges ; otherAges ];
%             fullGroups = [ gspGroups ; otherGroups];
%             if strcmp( setName1 , setName2 )
%                 fullData = zscore(gspData);
%                 fullAges = gspAges;
%                 fullGroups = gspGroups;
%             end
%             normData = fullData ;
%             if strcmp( reduce , 'pca' ) || strcmp( reduce , 'none' ) || strcmp( reduce , 'ICPQR_data' )
%                 eps = 0;
%             else
%                 eps = estimate_epsilon( ...
%                         pdist2( normData , normData ) );
%                 
%             end
%             for curMu = mu
%                 fprintf('method is %s , epsilon is %s , mu is %s \n' , reduce , num2str(eps) , num2str(curMu) );
%                 
%                 name = sprintf('newData/sn1_%s_sn2_%s_method is %s , epsilon is %s , mu is %s filterAges_%d.mat' ,...
%                     setName1, setName2, reduce , num2str(eps) , num2str(curMu) , AGES_FILTER );
%                 name = fullfile( setName1 , name );
%                 
%                 if exist(name , 'file' )
%                     temp = load( name );
%                     reducingData = temp.reducingData;
%                 else
%                     reducingData = getReducingData( fullData , reduce , eps , curMu );
%                     save(name , 'reducingData' );
%                 end
%                 
%                 if strcmp( reduce , 'PDME') || strcmp( reduce , 'ICPQR')
%                     reducingData = reducingData(: , 2 : end );
%                 end
%                 gspData = reducingData( 1 : size(gspData  , 1 ) , : );
%                 
%                 if strcmp( setName1 , setName2 )
%                     relevantData = gspData ;
%                     relevantGroups = gspGroups ;
%                 else
%                     otherData = reducingData( size(gspData  , 1 ) + 1 : end , : );
%                     relevantData = [gspData ; otherData ];
%                     relevantGroups = [gspGroups ; otherGroups ];
%                 end
%                 [U,S,V] = svd(relevantData);
%                 if any( size(S) <= 1 )
%                     continue
%                 end
%                 eigenValuesNormalized = diag( S ) / S( 1 , 1 );
%                 maxDim = findMaxDim(eigenValuesNormalized ) ;%+ 10;
%                 if strcmp( reduce , 'none')
%                     maxDim = size(reducingData , 2 );
%                 end
%                 maxDim = min( maxDim , size(reducingData , 2 ) );
%                 dim = maxDim
%                 if dim < 0
%                     break;
%                 end
%                 if strcmp( setName1 , setName2 )
%                     [cfMat , classification ,model ]  = tryClassifyGetclassification( relevantData( : , 1 : dim ) , relevantGroups );
%                 else
%                     if isempty( otherData )
%                         continue
%                     end
%                     [ cfMat , testError , classification , model ] = myEnssembleLearning( gspData(: , 1 : dim ), ...
%                         gspGroups , otherData( : , 1 :dim ) , otherGroups , ...
%                         unique( otherGroups ) , 'treeBager' );
%                     errorIndices = [ errorIndices , testError ];
%                     
%                 end
%                 s1 = cfMat( 1 , 1 ) / sum( cfMat(: , 1 ) );
%                 s2 = cfMat( 2 , 2 ) / sum( cfMat(: , 2 ) );
%                 succRate = [ s1 , s2 ] ;
%                 scRate =sum( diag( cfMat ) ) / sum2( cfMat ) ;
%                 models{end+1} = model;
%                 kfoldResult = [ kfoldResult ; i , dim , eps , curMu , succRate];
%                 classificationResult = [ classificationResult , [ i ; dim ; eps ; curMu ; scRate ; classification ] ];
% 
%             end
%         end
%     save( fullfile( setName1 , sprintf( '%s_supervisedResult_filterAges_%d.mat' , setName2 , AGES_FILTER ) ) , 'kfoldResult' , 'reduceMethods' , 'methods' , 'errorIndices' , 'models' ,'otherGroups');
%     end
% end

%% to calc predicats
% 
MU = 10.^(-8 : 2 : 2);

for AGES_FILTER = [1,0]
    for testSet = {'israel', 'beijing','cambridge'}
        testSet = cell2mat( testSet );
        for trainSet = { 'GSP_VBM' , testSet }
            classificationResult = [];
            trainSet = cell2mat( trainSet );
            models = [];
            for i = 1 : length( reduceMethods )
                reduce = reduceMethods{ i };
                if strcmp( reduce , 'pca' ) || strcmp( reduce , 'dm' ) || strcmp( reduce , 'none' )
                    mu = 0;
                else
                    mu = MU;
                end
                a = load( fullfile( testSet ,'allDataGroupsOriginal.mat' ) );
                b = load( fullfile( trainSet ,'allDataGroupsOriginal.mat' ) );
                beforeZscore = [a.allData ; b.allData ];
                testData = a.allData; trainData = b.allData;
                testAges = a.allAges; trainAges = b.allAges;
                testGroups = a.allGroups; trainGroups = b.allGroups;
                
                if strcmp( testSet , trainSet)
                    fullData = zscore(trainData);
                    fullAges = trainAges;
                    fullGroups = trainGroups;
                else
                    fullData =[ zscore( trainData ) ; zscore( testData ) ];
                    fullAges = [trainAges ; testAges ];
                    fullGroups = [ trainGroups ; testGroups];
                end
                trainLen = length(trainAges);
                if AGES_FILTER
                    ind = fullAges >= 19 & fullAges <= 35;
                    trainLen = sum( trainAges >= 19 & trainAges <= 35 );
                    trainGroups = trainGroups( trainAges >= 19 & trainAges <= 35 );
                    testGroups = testGroups( testAges >= 19 & testAges <= 35 );
                    fullData = fullData( ind , : );
                    fullAges = fullAges( ind );
                    fullGroups = fullGroups( ind );
                end
                normData = fullData ;
                if strcmp( reduce , 'pca' ) || strcmp( reduce , 'none' ) || strcmp( reduce , 'ICPQR_data' )
                    eps = 0;
                else
                    eps = estimate_epsilon( ...
                        pdist2( normData , normData ) );
                end
                for curMu = mu
                    fprintf('method is %s , epsilon is %s , mu is %s \n' , reduce , num2str(eps) , num2str(curMu) );
                    
                    name = sprintf('newData/sn1_%s_sn2_%s_method is %s , epsilon is %s , mu is %s filterAges_%d.mat' ,...
                        trainSet, testSet, reduce , num2str(eps) , num2str(curMu) , AGES_FILTER);
                    name = fullfile( 'GSP_VBM' , name );
                    
                    if exist(name , 'file' )
                        temp = load( name );
                        reducingData = temp.reducingData;
                    else
                        reducingData = getReducingData( fullData , reduce , eps , curMu );
                        save(name , 'reducingData' );
                    end
                    
                    if strcmp( reduce , 'PDME') || strcmp( reduce , 'ICPQR')
                        reducingData = reducingData(: , 2 : end );
                    end
                    trainData = reducingData( 1 : trainLen , : );
                    
                    if strcmp( testSet , trainSet )
                        relevantData = trainData ;
                        relevantGroups = trainGroups ;
                    else
                        testData = reducingData( trainLen + 1 : end , : );
                        relevantData = [trainData ; testData ];
                        relevantGroups = [trainGroups ; testGroups];
                    end
                    [U,S,V] = svd(relevantData);
                    if any( size(S) <= 1 )
                        continue
                    end
                    eigenValuesNormalized = diag( S ) / S( 1 , 1 );
                    maxDim = findMaxDim(eigenValuesNormalized );% + 15;
                    if strcmp( reduce , 'none')
                        maxDim = size(reducingData , 2 );
                    end
                    maxDim = min( maxDim , size(reducingData , 2 ) );
                    for dim = maxDim
                        if dim < 0
                            break;
                        end
                        if strcmp( testSet , trainSet)
                            [cfMat , classification, model] = tryClassifyGetclassification( relevantData( : , 1 : dim ) , relevantGroups );
                        else
                            if isempty( trainData )
                                continue
                            end
                            [ cfMat , testError , classification , model] = myEnssembleLearning( trainData(: , 1 : dim ), ...
                                trainGroups , testData( : , 1 :dim ) , testGroups, ...
                                unique( trainGroups ) , 'treeBager' );
                            
                        end
                        scRate =sum( diag( cfMat ) ) / sum2( cfMat ) ;
                        models{end+1} =model;
                        classificationResult = [ classificationResult , [ i ; dim ; eps ; curMu ; scRate ; classification ] ];
                    end
                end
            end
            save( fullfile( 'GSP_VBM' , sprintf( 'train_%s_test_%s_classification_testing_agesFilter_%d.mat' , trainSet , testSet , AGES_FILTER) ) , 'classificationResult' , 'reduceMethods' , 'methods' , 'testGroups', 'models');
        end
    end
    
end

