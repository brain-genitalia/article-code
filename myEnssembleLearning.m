function [ cfMat , testError , classification , modelRes]  = myEnssembleLearning(xtrain , ytrain , xtest , ytest , order , model , numTrees)
% this function get a training and testing set and the model
%% globals

if ~exist( 'numTrees' , 'var')
    numTrees = 40;
end
modelRes = [];
%% treeBager
switch model
    case 'knn'
        tot = 0;
        for NN = 9
            curMyClass = knnclassify( xtest , xtrain , ytrain , NN );
            cur = sum( curMyClass == ytest );
            if cur > tot
                myclass = curMyClass;
            end
        end
    case 'treeBager'
        cost = [ 0 1 ; 1 0];
        w = ones(size(ytrain));% w(ytrain == 1) = w(ytrain == 1) * 2;
        t = ClassificationTree.template('Prune' , 'on' , 'MergeLeaves' , 'on' , 'MinLeaf' , 0.01 * length(ytrain));
        modelRes = fitensemble(xtrain , ytrain,'bag',100, t , 'type' , 'classification' , 'weights' , w  , 'cost' , cost);
        myclass = modelRes.predict( xtest );
    case 'adaBoost'        
        cost = [ 0 1 ; 1 0];
        w = ones(size(ytrain));% w(ytrain == 1) = w(ytrain == 1) * 2;
        t = ClassificationTree.template('Prune' , 'on' , 'MergeLeaves' , 'on' , 'MinLeaf' , 0.01 * length(ytrain));
        modelRes = fitensemble(xtrain , ytrain,'AdaBoostM1',numTrees, t , 'type' , 'classification' , 'weights' , w  , 'cost' , cost);
        myclass = modelRes.predict( xtest );
    case 'svm'
        options = statset('MaxIter',1000000,'Display','off');
        svmModel = svmtrain(xtrain , ytrain , 'kernel_function' , 'linear',...
            'options' , options);
        modelRes = svmModel;
        myclass = svmclassify( svmModel , xtest );        
    case 'svmqua'        
        svmModel = svmtrain(xtrain , ytrain , 'kernel_function' , 'quadratic');
        myclass = svmclassify( svmModel , xtest );        
    case 'Naive Bayes'        
        NBModel = fitNaiveBayes(xtrain,ytrain);
        myclass = predict(NBModel,xtest);        
    case 'PTE'
        [ ~ , myclass ]= findErrorPTEDictiomary( xtrain,ytrain,xtest,ytest);
    
    case 'BDT'
        inputDim = size( xtrain , 2 );
        sx = zeros( inputDim );
        sy = zeros( inputDim );
        classInd = find( ytrain == 1 );
        mx = mean( xtrain( classInd , : ) );
        for i = 1 : length( classInd )
            sx = sx + (xtrain(classInd(i) , : ) - mx)' * (xtrain(classInd(i) , : ) - mx);
        end
        
        classInd = find( ytrain == 0 );
        for i = 1 : length( classInd )
            sy = sy + (xtrain(classInd(i) , : ) - mx)' * (xtrain(classInd(i) , : ) - mx);
        end
        mu = 0.005; gamma = 0.005;
        sx = (1 - mu ) * sx + mu / inputDim * ( trace( sx ) * eps ) * eye( inputDim);
        sy = (1 - gamma ) * sy + gamma / inputDim * ( trace( sx ) * eps ) * eye( inputDim);
        
        [v , e ] = svd( inv( sx ) * sy );
        transMatrix = v * sqrt( e );
        %     transMatrix = transMatrix( : , 1 : numFeature );
        
        newTrain = xtrain * transMatrix;
        pos = mean( newTrain(ytrain == 1 , 1 ) ) ;
        neg = mean( newTrain(ytrain == 0 , 1 ) ) ;
        
        newTest = xtest * transMatrix;
        if pos > neg
            thr = prctile( newTrain(ytrain == 1 , 1 ) , 2 );
            myclass = double( newTest(: , 1 ) > thr );
        else
            thr = prctile( newTrain(ytrain == 1 , 1 ) , 98);
            myclass = double( newTest(: , 1 ) < thr ) ;
        end
end
classification = myclass;
testError = ytest ~= myclass;
cfMat = confusionmat(myclass , ytest,'order',order);

end

