   % DESCRIPTION
% -----------
% Normalization of the input dataset using bin count
% function [XB,TNS] = Training_BinFeatures_new(X, P1, P2)
% 
% INPUT
% ----- 
% X                                - Input data file - csv format
%                                    Columns are different data types
%                                    Rows are time slices or # of connections
% P1                               - Number of input features (columns of X)
% P2                               - Number of bins
% 
% OUTPUT
% ------
% XB                               - Data tranformed to bins
% TNS                              - min,bin step,max of X
%
% RELATED FUNCTIONS
% -----------------
% Data_train                      : PARENT

function [training_norm_points, training_norm_epsilons, training_norm_sums] = Training_BinFeatures(training_file, number_of_input_parameters, num_bins)

training_norm_points = zeros(size(training_file,1),number_of_input_parameters);
% training_norm_sums = zeros(num_bins,number_of_input_parameters);
training_norm_epsilons = zeros(1,number_of_input_parameters);
bin_range = zeros(num_bins,number_of_input_parameters);

n_zeros = length(find(training_file==0))/length(training_file(:))*100;
if(n_zeros > 90)
    fprintf('Warning, %4.2f%% of the matrix is made of zeros ... \n' , n_zeros);
end
min_val = min(training_file);
max_val = max(training_file);
bin_step = (max_val-min_val)/(num_bins-1);
for i = 1:number_of_input_parameters
    xcol = training_file(:,i);
%     n_zeros = length(find(xcol==0))/length(xcol);
%     training_norm_epsilons(:,i) =  n_zeros;
    if(n_zeros > 90)
        [dum,~] = hist(xcol,10);
    else
        [dum,~] = hist(xcol,100);
    end
    perc_zero = sum(~dum)/length(dum)*100;
    training_norm_epsilons(:,i) =  perc_zero;
%     if(bin_step(i)~=0)
%     if(n_zeros < 0.5)
    if(perc_zero < 70)
        bin_range(:,i) = (min_val(i):bin_step(i):max_val(i))';
        [~,bin] = histc(xcol,bin_range(:,i));
        training_norm_points(:,i) = bin/num_bins;
        training_norm_sums(:,i) = {bin_range(:,i)};
    else
%         training_norm_points(:,i) = ones(size(training_file,1),1);
%         training_norm_sums(:,i) = (min_val(i)+eps)*ones(num_bins,1);
        max_col = max(xcol);
        if(max_col == 0)
            max_col = 1;
        end
        training_norm_points(:,i) = xcol/max_col;
        training_norm_sums(:,i) = {max_col};
    end
end
% training_norm_points = training_norm_points/num_bins;
