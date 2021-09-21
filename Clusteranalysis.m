function [] = Clusteranalysis(overall_PCAmatrix, ClusterAnalysis_index, divide_mode, raw_data)

[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);
overall_PCAmatrix = reshape(overall_PCAmatrix, [trialNum, timespan*coordinate*labelNum]);
overall_PCAmatrix = GroupData_Mouse(overall_PCAmatrix, divide_mode, raw_data);
trial_markers = overall_PCAmatrix(:,end);
overall_PCAmatrix(:,end) = [];


%% 1st, use t-sne to visualize the behavior matrix clustering.
% t-sne is a nonlinear data grouping algorithm. So it couldn't be used to do prediction on test dataset
if ClusterAnalysis_index(1) == 1
    tsne_output = tsne(overall_PCAmatrix,'Algorithm','exact','Distance','euclidean','NumDimensions',3);    % clustering with t-sne
    tsne_output = [tsne_output, trial_markers];
    
    DR_visualization_Mouse(tsne_output, [], size(overall_PCAmatrix,1), 'tsne', divide_mode, [1,1,0,0])
end


end