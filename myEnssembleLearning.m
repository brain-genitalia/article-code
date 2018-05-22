function [ cfMat , testError , classification , modelRes]  = myEnssembleLearning(xtrain , ytrain , xtest , ytest , order , model )
% this function get a training and testing set and the model
%% globals

modelRes = [];
%% treeBager
switch model
    case 'treeBager'
        cost = [ 0 1 ; 1 0];
        w = ones(size(ytrain));% w(ytrain == 1) = w(ytrain == 1) * 2;
        t = ClassificationTree.template('Prune' , 'on' , 'MergeLeaves' , 'on' , 'MinLeaf' , 0.01 * length(ytrain));
        modelRes = fitensemble(xtrain , ytrain,'bag',100, t , 'type' , 'classification' , 'weights' , w  , 'cost' , cost);
        myclass = modelRes.predict( xtest );
    case 'svm'
        options = statset('MaxIter',1000000,'Display','off');
        svmModel = svmtrain(xtrain , ytrain , 'kernel_function' , 'linear',...
            'options' , options);
        modelRes = svmModel;
        myclass = svmclassify( svmModel , xtest );        

end
classification = myclass;
testError = ytest ~= myclass;
cfMat = confusionmat(myclass , ytest,'order',order);

end

