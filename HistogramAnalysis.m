function [Signi_idx] = HistogramAnalysis(fPath, overall_PCAmatrix, divide_mode, raw_data)

%% Getting the location of each label in each trial
global mouse_name
mousename = mouse_name;
[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);
temp = reshape(overall_PCAmatrix, [trialNum, timespan*coordinate*labelNum]);
temp = GroupData_Mouse(temp, divide_mode, raw_data);
group_info = temp(:, end);


lateral_path = [fPath 'Lateral\'];
bottom_path = [fPath 'Bottom\'];

lateral_videos = dir([lateral_path mousename '_SpatialDisc_*.csv']);
bottom_videos = dir([bottom_path mousename '_SpatialDisc_*.csv']);


lateral_labelNames = Import_LabelNames([lateral_path lateral_videos(20).name], 2, 3);
lateral_labelNames(:, 43:end) = [];
bottom_labelNames = Import_LabelNames([bottom_path bottom_videos(20).name], 2, 3);  % just use the 20th video's label names
bottom_labelNames(:, 31:36) = [];
clear temp lateral_path bottom_path lateral_videos bottom_videos


lateral_x = {};
lateral_y = {};
bottom_x = {};
bottom_y = {};
for a = 1 : labelNum
    for b = 1 : trialNum
        if a <= (size(lateral_labelNames, 2))/3
            this_label = lateral_labelNames(1,a*3-2);
            lateral_x.(this_label)(b,:) = reshape(overall_PCAmatrix(b, :, 1, a), [1, timespan]);
            lateral_y.(this_label)(b,:) = reshape(overall_PCAmatrix(b, :, 2, a), [1, timespan]);
            
        else
            this_label = bottom_labelNames(1,(a - size(lateral_labelNames, 2)/3)*3-2);
            bottom_x.(this_label)(b,:) = reshape(overall_PCAmatrix(b, :, 1, a), [1, timespan]);
            bottom_y.(this_label)(b,:) = reshape(overall_PCAmatrix(b, :, 2, a), [1, timespan]);         
        end
    end
end


%% getting histogram of each group per label
group_idx = unique(group_info);

All_Labels.lateral_x = lateral_x;
All_Labels.lateral_y = lateral_y;
All_Labels.bottom_x = bottom_x;
All_Labels.bottom_y = bottom_y;
All_Labels_backup = All_Labels;
fx = fieldnames(All_Labels);
for n = 1:numel(fx)
    fn = fieldnames(All_Labels.(fx{n}));
    for k = 1:numel(fn)
        
        all_trials = All_Labels.(fx{n}).(fn{k});
        
        All_Labels.(fx{n}).([fn{k} num2str(group_idx(1))]) = all_trials(group_info == group_idx(1), :);
        All_Labels.(fx{n}).([fn{k} num2str(group_idx(2))]) = all_trials(group_info == group_idx(2), :);
        if length(group_idx) > 2
            All_Labels.(fx{n}).([fn{k} num2str(group_idx(3))]) = all_trials(group_info == group_idx(3), :);
        end
        if length(group_idx) > 3
            All_Labels.(fx{n}).([fn{k} num2str(group_idx(4))]) = all_trials(group_info == group_idx(4), :);
        end
        if length(group_idx) > 4
            All_Labels.(fx{n}).([fn{k} num2str(group_idx(5))]) = all_trials(group_info == group_idx(5), :);
        end
        if length(group_idx) > 5
            All_Labels.(fx{n}).([fn{k} num2str(group_idx(6))]) = all_trials(group_info == group_idx(6), :);
        end
    end
end
clear lateral_x lateral_y bottom_x bottom_y fx fn n k a b all_trials this_label


%% Finding out from which frame the labels are able to predict the classes
Signi_idx = {};
if length(group_idx) == 2
    fx = fieldnames(All_Labels_backup);
    for n = 1:numel(fx)
        fn = fieldnames(All_Labels_backup.(fx{n}));
        Signi_idx.(fx{n}) = {};
        for k = 1:numel(fn)
            group1 = All_Labels.(fx{n}).([fn{k} num2str(group_idx(1))]);
            group2 = All_Labels.(fx{n}).([fn{k} num2str(group_idx(2))]);
            [h,p]=ttest2(group1, group2);

            yy = find(p<0.001, 10);  % in case the outlier value, we need 10 p<0.001 at least
            zz = find(p<0.001, 10, 'last');
            if length(yy) == 10
                idx_init = yy(10) - 9;
            else
                idx_init = NaN;
            end
            if length(zz) == 10
                idx_last = zz(10);
            else
                idx_last = NaN;
            end
            
            Signi_idx.(fx{n}){k,1} = (fn{k});
            Signi_idx.(fx{n}){k,2} = idx_init;
            Signi_idx.(fx{n}){k,3} = idx_last;
                  
        end
    end
    
elseif length(group_idx) == 3
    if group_idx(1) == 0
        group_idx(1) = [];
        fx = fieldnames(All_Labels_backup);
        for n = 1:numel(fx)
            fn = fieldnames(All_Labels_backup.(fx{n}));
            Signi_idx.(fx{n}) = {};
            for k = 1:numel(fn)
                group1 = All_Labels.(fx{n}).([fn{k} num2str(group_idx(1))]);
                group2 = All_Labels.(fx{n}).([fn{k} num2str(group_idx(2))]);
                [h,p]=ttest2(group1, group2);
                
                yy = find(p<0.001, 10);  % in case the outlier value, we need 10 p<0.001 at least
                zz = find(p<0.001, 10, 'last');
                if length(yy) == 10
                    idx_init = yy(10) - 9;
                else
                    idx_init = NaN;
                end
                if length(zz) == 10
                    idx_last = zz(10);
                else
                    idx_last = NaN;
                end
                
                Signi_idx.(fx{n}){k,1} = (fn{k});
                Signi_idx.(fx{n}){k,2} = idx_init;
                Signi_idx.(fx{n}){k,3} = idx_last;
                
            end
        end
    else
        fprintf(2, 'This Grouping is tricky. Please check the data! \n');
        return
    end
    
elseif length(group_idx) > 3
    fprintf(2, 'MORE than 2 classes for histogram classes. This will not work! \n');
    return
else
    fprintf(2, 'Something WRONG with the histogram classes! \n');
    return
end
clear group1 group2 p h idx_init idx_last


%% Plotting
lateral_Plotting = NaN(2, size(Signi_idx.lateral_x,1));
bottom_Plotting = NaN(2, size(Signi_idx.bottom_x,1));
if contains(divide_mode,'former') == 0
    order_idx = 2;
    Title = ['The FIRST frame which shows significant difference between classes, ', mousename, ', ', divide_mode];
else
    order_idx = 3;
    Title = ['The LAST frame which shows significant difference between classes, ', mousename, ', ', divide_mode];
end

for a = 1 : size(Signi_idx.lateral_x,1)
    if ~isempty(Signi_idx.lateral_x{a, order_idx})
        lateral_Plotting(1,a) = Signi_idx.lateral_x{a, order_idx};
    end
    if ~isempty(Signi_idx.lateral_y{a, order_idx})
        lateral_Plotting(2,a) = Signi_idx.lateral_y{a, order_idx};
    end
end

for a = 1 : size(Signi_idx.bottom_x,1)
    if ~isempty(Signi_idx.bottom_x{a, order_idx})
        bottom_Plotting(1,a) = Signi_idx.bottom_x{a, order_idx};
    end
    if ~isempty(Signi_idx.bottom_y{a, order_idx})
        bottom_Plotting(2,a) = Signi_idx.bottom_y{a, order_idx};
    end
end

figure;
subplot(1,2,1);
scatter(lateral_Plotting(1,:), categorical(lateral_labelNames(1,1:3:end)), 20, 'b','filled');
hold on 
scatter(lateral_Plotting(2,:), categorical(lateral_labelNames(1,1:3:end)), 20, 'r','filled');
legend({'x', 'y'});
title([Title, ', lateral camera']);
xlabel('Frame Number');
xlim([1 timespan]);

subplot(1,2,2);
scatter(bottom_Plotting(1,:), categorical(bottom_labelNames(1,1:3:end)), 20, 'b','filled');
hold on 
scatter(bottom_Plotting(2,:), categorical(bottom_labelNames(1,1:3:end)), 20, 'r','filled');
legend({'x', 'y'});
title([Title, ', bottom camera']);
xlabel('Frame Number');
xlim([1 timespan]);

hold off


end