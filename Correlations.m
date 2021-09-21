function [] = Correlations(overall_PCAmatrix, raw_data, variableList)

global mouse_name
mousename = mouse_name;
[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);


%% Getting the correlation between variables
temp = reshape(overall_PCAmatrix, [trialNum, timespan*coordinate*labelNum]);

for a = 1 : length(variableList)
    temp = GroupData_Mouse(temp, variableList{a}, raw_data);
end

group_info = temp(:, end-length(variableList)+1:end);

% remove all no-response trials, because most of them gathered at the end part of the sessions, inducing nosense correlation
ttt = unique([find(group_info(:,2) == 0);find(group_info(:,3) == 0); find(group_info(:,4) == 0);find(group_info(:,5) == 0)]);
group_info(ttt,:) = [];


figure;
heatmap(variableList, variableList, corrcoef(group_info));
title(['Correlation between Variables, ', mousename]);

clear a ttt temp



%% Getting the correlation between body parts
global Laterl_labels Bottom_labels
labels = [Laterl_labels, Bottom_labels];


% temp = reshape(overall_PCAmatrix, [trialNum*timespan*coordinate, labelNum]);
% figure;
% heatmap(labels, labels, corrcoef(temp));
% title(['Correlation between Variables, ', mousename]);
% The 4 lines above plot the raw correlation between labels in Cartesian coordinates
% To get the more meaningful correlatin between the movements of different labels, we need to employ polar coordinates

temp = diff(overall_PCAmatrix, 1, 2);
temp = reshape(temp, [trialNum*(timespan-1), coordinate, labelNum]);

temp_polar = NaN(size(temp));

for a = 1 : size(temp, 3)
    [theta,rho] = cart2pol(temp(:,1,a), temp(:,2,a));
    temp_polar(:,1,a) = theta;
    temp_polar(:,2,a) = rho;
end

temp_polar_theta = reshape(temp_polar(:,1,:), [trialNum*(timespan-1), labelNum]);
temp_polar_rho = reshape(temp_polar(:,2,:), [trialNum*(timespan-1), labelNum]);

figure;
heatmap(labels, labels, corrcoef(temp_polar_rho));
title(['The Movement Speed Correlation between Variables, ', mousename]);

figure;
heatmap(labels, labels, corrcoef(temp_polar_theta));
title(['The Movement Direction Correlation between Variables, ', mousename]);


end