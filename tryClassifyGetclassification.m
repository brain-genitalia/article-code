function [cfMat , classification ,model ] = tryClassifyGetclassification( data , groups )

global methods 

cp = cvpartition(groups,'k',10); % Stratified cross-validation
classification = nan( size( groups ) );
for m = 1 : length( methods )
    for part = 1 : cp.NumTestSets
        trainInd = training(cp,part);
        testInd = test( cp , part );
        curTrainData = data( trainInd , : );
        curTestData = data( testInd , : );
        curTestGroup = groups( testInd );
        curTrainGroup = groups( trainInd );
        order = unique(curTrainGroup); % Order of the group labels
        
        [ ~ , ~ , curClassification ,model] = myEnssembleLearning( curTrainData, ...
            curTrainGroup , curTestData , curTestGroup, ...
            order , methods{m} );
        classification( testInd ) = curClassification;
%         scores( part ) = sum( diag( cfMat ) ) / sum2( cfMat ) ;
    end
%     [~ , ind ] = sort( scores );
%     bestModel = models{ ind( round( cp.NumTestSets / 2) ) };
%     classification = svmclassify( bestModel , data );
    cfMat = confusionmat(classification , groups,'order',order);

%     scRate = sum( classification == groups ) / length( groups );
end
end