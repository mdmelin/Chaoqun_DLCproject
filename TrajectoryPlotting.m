function [] = TrajectoryPlotting(overall_PCAmatrix, raw_data, divide_mode, plotting_idx)

global mouse_name   
mousename = mouse_name;

[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);

%% Plotting the trajectories of different conditions, in this case, we use polar coordinate system
if plotting_idx(1) == 1
    
    %% Preparing the PCA base and group information
    temp = diff(overall_PCAmatrix, 1, 2);
    temp = mean(temp, 1);
    temp = squeeze(temp);
    
    temp_polar = NaN(size(temp));
    
    for a = 1 : size(temp, 3)
        [theta,rho] = cart2pol(temp(:,1,a), temp(:,2,a));
        temp_polar(:,1,a) = theta;
        temp_polar(:,2,a) = rho;
    end
    
    mean_polar_theta = squeeze(temp_polar(:,1,:));
    mean_polar_rho = squeeze(temp_polar(:,2,:));

    
    [PCA_bases_theta,~,~,~,explained_theta,~] = pca(mean_polar_theta);
    [PCA_bases_rho,~,~,~,explained_rho,~] = pca(mean_polar_rho);
    
    clear temp theta rho temp_polar a
    
   
    temp = overall_PCAmatrix;
    temp = reshape(temp, [trialNum, timespan*coordinate*labelNum]);
    temp = GroupData_Mouse(temp, divide_mode, raw_data);
    group_inf = temp(:, end);
    clear temp
    
    
    
    %% Getting the average value of each label and transform them into polar coordinate system
    temp = diff(overall_PCAmatrix, 1, 2);
    group_num = unique(group_inf);
    divided_trials = {};
    if length(group_num) == 2
        divided_trials{1} = temp(group_inf == group_num(1) , :,:,:);
        divided_trials{2} = temp(group_inf == group_num(2) , :,:,:);
        
    elseif length(group_num) == 3
        divided_trials{1} = temp(group_inf == group_num(1) , :,:,:);
        divided_trials{2} = temp(group_inf == group_num(2) , :,:,:);
        divided_trials{3} = temp(group_inf == group_num(3) , :,:,:);
        
    elseif length(group_num) == 6
        divided_trials{1} = temp(group_inf == group_num(1) , :,:,:);
        divided_trials{2} = temp(group_inf == group_num(2) , :,:,:);
        divided_trials{3} = temp(group_inf == group_num(3) , :,:,:);
        divided_trials{4} = temp(group_inf == group_num(4) , :,:,:);
        divided_trials{5} = temp(group_inf == group_num(5) , :,:,:);
        divided_trials{6} = temp(group_inf == group_num(6) , :,:,:);
    end
    
    
    for a = 1 : length(group_num)
        divided_trials{a} = mean(divided_trials{a}, 1); 
        divided_trials{a} = squeeze(divided_trials{a});
        
        for b = 1 : size(divided_trials{a}, 3)
            [theta,rho] = cart2pol(divided_trials{a}(:,1,b), divided_trials{a}(:,2,b));
            divided_trials{a}(:,1,b) = theta;
            divided_trials{a}(:,2,b) = rho;
        end
    end
    
    clear a b
    
    
    %% Applying PCA based and plotting
    trajectory_direction = {};
    trajectory_speed = {};
    
    for a = 1 : length(group_num)
        trajectory_direction{a} = squeeze(divided_trials{a}(:,1,:)) * PCA_bases_theta(:,1:3);
        trajectory_speed{a} = squeeze(divided_trials{a}(:,2,:)) * PCA_bases_rho(:,1:3);     
    end
    
    
    figure;
    hold on
    for b = 1 : (timespan-1)
        for c = 1 : length(group_num)
            plot3(trajectory_speed{c}(1:b,1),trajectory_speed{c}(1:b,2),trajectory_speed{c}(1:b,3),'LineWidth', 1.5);
            hold on
        end
        
        if b >= 1 && b < 15
            TITLE = ['Frame ', num2str(b), ', Baseline,  ', divide_mode];
        elseif b >= 15 && b < 45
            TITLE = ['Frame ', num2str(b), ', Stimulus On,  ', divide_mode];
        elseif b >= 45 && b < 60
            TITLE = ['Frame ', num2str(b), ', Delay,  ', divide_mode];
        elseif b >= 60
            TITLE = ['Frame ', num2str(b), ', Spouts In,  ', divide_mode];
        end
        title(TITLE);
        xlabel('PC1');
        ylabel('PC2');
        zlabel('PC3');
        LEGEND = getLegend(divide_mode);
        legend(LEGEND);
        rotate3d on
        pause(0.3);
        if b < (timespan-1)
            clf('reset')
        end
    end
    
    hold off

end

end




function [LEGEND] = getLegend(divide_mode)

if isequal(divide_mode, 'opto')
    LEGEND = {'Control', 'Opto'};
    
elseif isequal(divide_mode, 'optotype')
    LEGEND = {'Control', 'Type1', 'Type2', 'Type3', 'Type4', 'Type5'};
    
elseif isequal(divide_mode, 'outcome')
    LEGEND = {'No response', 'Correct', 'Wrong'};
    
elseif isequal(divide_mode, 'responseside')
    LEGEND = {'No response', 'Left', 'Right'};
    
elseif isequal(divide_mode, 'formeroutcome')
    LEGEND = {'No response', 'Correct', 'Wrong'};
    
elseif isequal(divide_mode, 'formerresponseside')
    LEGEND = {'No response', 'Left', 'Right'};
    
elseif isequal(divide_mode, 'random')
    LEGEND = {'Random group 1', 'Random group 2'};  
end

end