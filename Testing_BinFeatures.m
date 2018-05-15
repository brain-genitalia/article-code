% DESCRIPTION
% -----------
% Normalization of the tested dataset
%
% function TNX = Testing_BinFeatures_new(TNS, TCF, P)
% 
% INPUT
% ----- 
% TNS                              - Sum or mean of normalized training Data columns
% TCF                              - Testing_csv_file
% P1                               - Number of input features (columns)
% P2                               - Number of bins
% 
% OUTPUT
% ------
% TNX                              - Data transformed to bins
%
% RELATED FUNCTIONS 
% -----------------
% Data_test                        : PARENT 
% 

function testing_norm_points = Testing_BinFeatures(testing_file, number_of_input_parameters, training_norm_sums, num_bins, training_norm_epsilons)

testing_file = testing_file(:,1:number_of_input_parameters);
% testing_norm_points = zeros(size(testing_file));
bin_range = training_norm_sums;

for i=1:number_of_input_parameters
    if(iscell(bin_range))
        br = cell2mat(bin_range(:,i));
    else
        br = bin_range(:,i);
    end
%     if(training_norm_epsilons(i) < 0.5)
    if(training_norm_epsilons(i) < 70)
        step_training = min(diff(br))+eps;
        [~,bin] = histc(testing_file(:,i),br);
        testing_norm_points(:,i) = bin;
        inx_max = find(testing_file(:,i) > br(end));
        testing_norm_points(inx_max,i) = br(end) + floor((testing_file(inx_max,i)-br(end))/step_training);
        inx_min = find(testing_file(:,i) < br(1));
        testing_norm_points(inx_min,i) = br(1) + ceil((testing_file(inx_min,i)-br(1))/step_training);
        testing_norm_points(:,i) = testing_norm_points(:,i)./num_bins(i);
    else
       testing_norm_points(:,i) = testing_file(:,i)./br;
    end
end
% testing_norm_points = testing_norm_points./repmat(num_bins,[size(testing_norm_points,1) 1]);
