%% This script is based on the 3rd part of LinearClassifierPlus.
% The goal of this script is testing if the movement changes induced by opto inactivation in different windows are same or not
% The idea is switching the classifiers trained on different windows and testing their performance

function [] = LinearClassifierSwitch(overall_PCAmatrix, raw_data, plotting_idx)

global mouse_name
mousename = mouse_name;
global Laterl_labels Bottom_labels

[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);
overall_PCAmatrix_backup = overall_PCAmatrix;

%% 1st, Switching the classifiers between different windows of one area
if plotting_idx(1) == 1
    overall_PCAmatrix = reshape(overall_PCAmatrix_backup, [trialNum, timespan*coordinate*labelNum]);
    overall_PCAmatrix = GroupData_Mouse(overall_PCAmatrix, 'optotype_classifier', raw_data);
    
    % Note: the sample numbers should be balanced
    group_info = overall_PCAmatrix(:, end);
    unique_labels = unique(group_info); % After this step unique_labels will be [-100 -5 -4 -3 -2 -1 1 2 3 4 5 100]
    if length(unique_labels) ~= 12
        fprintf(2, 'There are more/less than 12 types of opto stimulations (6 types per areas)! \n');
        return
    end
    
    b = [];
    for nnn = 1 : length(unique_labels)
        b = [b, length(group_info(group_info == unique_labels(nnn)))];
    end
    sample_num = min(b);
    clear nnn b
    
    
    Accuracy_data = nan(10, 45, 10);   % (2 areas * 5 types) * 45 frames * 10 repeats
    Accuracy_shuffled = nan(10, 45, 10);
    Accuracy_WindowSwitch = nan(10, 5, 45, 10);    % (2 areas * 5 types) * 5 types * 45 frames * 10 repeats
    Accuracy_WindowSwitch_shuffled = nan(10, 5, 45, 10);
    
    for c = 1 : size(Accuracy_data, 3)
        idx = {};
        classes = {};
        for n = 1 : length(unique_labels)
            idx{n} = find(group_info == unique_labels(n));
            
            msize = numel(idx{n});
            ttt = randperm(msize);
            idx{n} = idx{n}(ttt(1:sample_num));
            
            classes{n} = overall_PCAmatrix(idx{n}, :);
        end
        
        clear msize ttt n idx
        
        for x = 1 : 10
            
            if x <= 5
                merged = [classes{1}; classes{x+1}];
            elseif x > 5
                merged = [classes{12}; classes{x+1}];
            end
            merged = merged(randperm(size(merged,1)), :);
            this_group_info = merged(:, end);
            merged(:,end) = [];
            
            merged = reshape(merged, [size(merged, 1), timespan, coordinate, labelNum]);
            
            ttt = unique(this_group_info);
            ttt = sort(abs(ttt));
            
            merged_Baseline = merged(:, 1:45, :, :);    
            merged_EarlyStim = merged(:, 15:59, :, :);
            merged_LateStim = merged(:, 30:74, :, :);
            merged_Delay = merged(:, 45:89, :, :);
            merged_Response = merged(:, 60:104, :, :);
            
            if ttt(1) == 1
                merged = merged_EarlyStim;   %merged(:, 15:59, :, :);
            elseif ttt(1) == 2
                merged = merged_Delay;       %merged(:, 45:89, :, :);
            elseif ttt(1) == 3
                merged = merged_Response;    %merged(:, 60:104, :, :);
            elseif ttt(1) == 4
                merged = merged_LateStim;    %merged(:, 30:74, :, :);
            elseif ttt(1) == 5
                merged = merged_Baseline;    %merged(:, 1:45, :, :);
            else
                fprintf(2, 'Unrecognizable Opto type! \n');
                return
            end
            
            
            
            for b = 1 : size(Accuracy_data,2)
                this_frame = reshape(merged(:,b,:,:), [size(merged, 1), coordinate*labelNum]);
                
                ClassifierModel = fitclinear(this_frame', this_group_info, 'ObservationsIn', 'columns', 'KFold', 5);
                % Please notice, using cross-validation would make ClassifierModel a ClassificationPartitionedLinear object,
                % which is a collection of cross-validated ClassificationLinear objects.
                % In this case, 'predict' function is only appliable for the separate saved ClassificationLinear objects.  
                % These ClassificationLinear objects are kept in ClassifierModel.Trained
                L_experiment = kfoldLoss(ClassifierModel);
                ShuffleModel = fitclinear(this_frame', this_group_info(randperm(length(this_group_info))), 'ObservationsIn', 'columns', 'KFold', 5);
                L_control = kfoldLoss(ShuffleModel);
                
                Accuracy_data(x, b, c) = (1 - L_experiment)*100;
                Accuracy_shuffled(x, b, c) = (1 - L_control)*100;
                
                
                [Accuracy_WindowSwitch, Accuracy_WindowSwitch_shuffled] = SwitchClassifier(Accuracy_WindowSwitch, Accuracy_WindowSwitch_shuffled, ...
                    x, b, c, classes, ClassifierModel, ShuffleModel, timespan, coordinate, labelNum, L_experiment, L_control);
                
                clear ClassifierModel ShuffleModel L_control L_experiment for_weight t
                
            end
            
        end
        
    end
    
    clear x ttt b c merged this_frame this_group_info idx
    
    
    ResultPlotting('frontal', Accuracy_WindowSwitch, Accuracy_WindowSwitch_shuffled);
    ResultPlotting('parietal', Accuracy_WindowSwitch, Accuracy_WindowSwitch_shuffled);
    
end



%% 2nd, Switching classifiers between frontal and parietal areas
if plotting_idx(2) == 1
    overall_PCAmatrix = reshape(overall_PCAmatrix_backup, [trialNum, timespan*coordinate*labelNum]);
    overall_PCAmatrix = GroupData_Mouse(overall_PCAmatrix, 'optotype_classifier', raw_data);
    
    % Note: the sample numbers should be balanced
    group_info = overall_PCAmatrix(:, end);
    unique_labels = unique(group_info); % After this step unique_labels will be [-100 -5 -4 -3 -2 -1 1 2 3 4 5 100]
    if length(unique_labels) ~= 12
        fprintf(2, 'There are more/less than 12 types of opto stimulations (6 types per areas)! \n');
        return
    end
    
    b = [];
    for nnn = 1 : length(unique_labels)
        b = [b, length(group_info(group_info == unique_labels(nnn)))];
    end
    sample_num = min(b);
    clear nnn b
    
    
    Accuracy_data = nan(10, 45, 10);   % (2 areas * 5 types) * 45 frames * 10 repeats
    Accuracy_shuffled = nan(10, 45, 10);
    Accuracy_FPSwitch = nan(10, 45, 10);
    Accuracy_FPSwitch_shuffled = nan(10, 45, 10);
    
    for c = 1 : size(Accuracy_data, 3)
        idx = {};
        classes = {};
        for n = 1 : length(unique_labels)
            idx{n} = find(group_info == unique_labels(n));
            
            msize = numel(idx{n});
            ttt = randperm(msize);
            idx{n} = idx{n}(ttt(1:sample_num));
            
            classes{n} = overall_PCAmatrix(idx{n}, :);
        end
        
        clear msize ttt n idx
        
        for x = 1 : 10
            
            if x <= 5
                merged = [classes{1}; classes{x+1}];
            elseif x > 5
                merged = [classes{12}; classes{x+1}];
            end
            merged = merged(randperm(size(merged,1)), :);
            this_group_info = merged(:, end);
            merged(:,end) = [];
            
            merged = reshape(merged, [size(merged, 1), timespan, coordinate, labelNum]);
            
            ttt = unique(this_group_info);
            ttt = sort(abs(ttt));
            
            merged_Baseline = merged(:, 1:45, :, :);
            merged_EarlyStim = merged(:, 15:59, :, :);
            merged_LateStim = merged(:, 30:74, :, :);
            merged_Delay = merged(:, 45:89, :, :);
            merged_Response = merged(:, 60:104, :, :);
            
            if ttt(1) == 1
                merged = merged_EarlyStim;   %merged(:, 15:59, :, :);
            elseif ttt(1) == 2
                merged = merged_Delay;       %merged(:, 45:89, :, :);
            elseif ttt(1) == 3
                merged = merged_Response;    %merged(:, 60:104, :, :);
            elseif ttt(1) == 4
                merged = merged_LateStim;    %merged(:, 30:74, :, :);
            elseif ttt(1) == 5
                merged = merged_Baseline;    %merged(:, 1:45, :, :);
            else
                fprintf(2, 'Unrecognizable Opto type! \n');
                return
            end
            
            
            
            for b = 1 : size(Accuracy_data,2)
                this_frame = reshape(merged(:,b,:,:), [size(merged, 1), coordinate*labelNum]);
                
                ClassifierModel = fitclinear(this_frame', this_group_info, 'ObservationsIn', 'columns', 'KFold', 5);
                % Please notice, using cross-validation would make ClassifierModel a ClassificationPartitionedLinear object,
                % which is a collection of cross-validated ClassificationLinear objects.
                % In this case, 'predict' function is only appliable for the separate saved ClassificationLinear objects.
                % These ClassificationLinear objects are kept in ClassifierModel.Trained
                L_experiment = kfoldLoss(ClassifierModel);
                ShuffleModel = fitclinear(this_frame', this_group_info(randperm(length(this_group_info))), 'ObservationsIn', 'columns', 'KFold', 5);
                L_control = kfoldLoss(ShuffleModel);
                
                Accuracy_data(x, b, c) = (1 - L_experiment)*100;
                Accuracy_shuffled(x, b, c) = (1 - L_control)*100;
                
                
                [Accuracy_FPSwitch, Accuracy_FPSwitch_shuffled] = SwitchFP(Accuracy_FPSwitch, Accuracy_FPSwitch_shuffled, ...
                    x, b, c, classes, ClassifierModel, ShuffleModel, timespan, coordinate, labelNum);
                
                clear ClassifierModel ShuffleModel L_control L_experiment for_weight t
                
            end
            
        end
        
    end
    
    clear x ttt b c merged this_frame this_group_info idx
    
    
    FPSwitchPlotting(Accuracy_FPSwitch, Accuracy_FPSwitch_shuffled);
    
end


end









%% Auxiliary Functions
%%
function [Accuracy_WindowSwitch, Accuracy_WindowSwitch_shuffled] = SwitchClassifier(Accuracy_WindowSwitch, Accuracy_WindowSwitch_shuffled, ...
    x, b, c, classes, ClassifierModel, ShuffleModel, timespan, coordinate, labelNum, kfoldL_experiment, kfoldL_control)

% Accuracy_WindowSwitch = nan(10, 5, 45, 10) --> (2 areas * 5 types) * 5 types * 45 frames * 10 repeats

for ii = 1 : 5
    if x <= 5
        merged = [classes{1}; classes{ii+1}];
    elseif x > 5
        merged = [classes{12}; classes{ii+6}];
    end
    
    merged = merged(randperm(size(merged,1)), :);
    this_group_info = merged(:, end);
    
    merged(:,end) = [];  
    merged = reshape(merged, [size(merged, 1), timespan, coordinate, labelNum]);
    
    ttt = unique(this_group_info);
    ttt = sort(abs(ttt));
    
    
    merged_Baseline = merged(:, 1:45, :, :);    % Used for testing switched classifiers
    merged_EarlyStim = merged(:, 15:59, :, :);
    merged_LateStim = merged(:, 30:74, :, :);
    merged_Delay = merged(:, 45:89, :, :);
    merged_Response = merged(:, 60:104, :, :);
    
    if ttt(1) == 1
        merged = merged_EarlyStim;
    elseif ttt(1) == 2
        merged = merged_Delay;
    elseif ttt(1) == 3
        merged = merged_Response;
    elseif ttt(1) == 4
        merged = merged_LateStim;
    elseif ttt(1) == 5
        merged = merged_Baseline;
    end
    
    
    this_frame = reshape(merged(:,b,:,:), [size(merged, 1), coordinate*labelNum]);
    % We have to change the group label to match ClassNames of classifier
    this_group_info(abs(this_group_info)<99) = ClassifierModel.ClassNames(abs(ClassifierModel.ClassNames)<99);
    
    
    % Calculating the loss of linear model. Please notice ClassifierModel is a ClassificationPartitionedLinear object
    if x <= 5
        if ii == x
            L_experiment = kfoldL_experiment;
            L_control = kfoldL_control;
        else
            L_experiment = TenFoldLoss(ClassifierModel, this_frame, this_group_info);
            L_control = TenFoldLoss(ShuffleModel, this_frame, this_group_info);
        end
        
    elseif x > 5
        if ii == (x-5)
            L_experiment = kfoldL_experiment;
            L_control = kfoldL_control;
        else
            L_experiment = TenFoldLoss(ClassifierModel, this_frame, this_group_info);
            L_control = TenFoldLoss(ShuffleModel, this_frame, this_group_info);
        end
    end

    Accuracy_WindowSwitch(x, ii, b, c) = (1 - L_experiment)*100;
    Accuracy_WindowSwitch_shuffled(x, ii, b, c) = (1 - L_control)*100; 
    
end

end




%% This function actually does not work as designed. For the matching dataset, the loss calcualted with this function is
% much higher than the loss got through kfoldLoss. The reason is unknown.
% However, this should not influence the predictig accuracy based on switched data. 
function Loss = TenFoldLoss(Model, this_frame, this_group_info)

Loss = nan(Model.KFold,1);
for i = 1 : Model.KFold
    test = this_frame(Model.ModelParameters.Generator.UseObsForIter(:,i)==0,:);
    test_label = this_group_info(Model.ModelParameters.Generator.UseObsForIter(:,i)==0);
    Loss_thisfold = loss(Model.Trained{i,1}, test, test_label);
    
    Loss(i) = Loss_thisfold;
    
    clear test test_label
end

Loss = mean(Loss);

end




%%
function ResultPlotting(area, Accuracy_WindowSwitch, Accuracy_WindowSwitch_shuffled)

% Optotype = 1 starts together with the stimulus. Usually it covers the first 0.5 s of the stimulus but depending on the session, it might stay on until the end of the delay period.
% Optotype = 2 starts at the end of the stimulus period (begin of delay period)
% Optotype = 3 starts at the end of the delay period (begin of response period)
% Optotype = 4 starts in the later part of the stimulus period and ends with the stimulus
% Optotype = 5 starts 0.5s before the stimulus and ends with stimulus onset
% rawdata.optoDur to check how long the stimulation lasted. In sessions where 5 types were used, it should always be 0.5s
figure;
if isequal(area, 'frontal')
    plotting_order = [5, 1, 4, 2, 3];
    for a = 1 : 5     
        for b = 1 : 5
            subplot(5, 5, (a-1)*5+b);
            classifier_plot = squeeze(Accuracy_WindowSwitch(plotting_order(a),plotting_order(b),:,:));  
            shuffled_plot = squeeze(Accuracy_WindowSwitch_shuffled(plotting_order(a),plotting_order(b),:,:));
            curve1 = stdshade(classifier_plot',0.4,'b');
            hold on;
            curve2 = stdshade(shuffled_plot',0.4,'r');

            
            ylim([30 100]);
            line([15 15;30 30]', [30 100;30 100]','Color','k','LineStyle','--');
            xticks([0 15 30 45])
            xticklabels({'-15','0','15','30'})
            set(gca,'box','off')
            set(gca,'tickdir','out')
            
            titles = {'Baseline', 'Early Stim', 'Late Stim', 'Delay', 'Response'};
            if a == 1
                TITLE = ['Data from ', titles{b}, ' Inactivation'];
                title(TITLE);
                
                if b == 5
                    legend([curve1, curve2], 'Frontal', 'Shuffled');
                end
            end
            
            if b == 1
                y_label = [titles{a}, ' Classifier'];
                ylabel(y_label, 'fontweight', 'bold');
            end
            
        end     
    end

    
elseif isequal(area, 'parietal')
    plotting_order = [10, 6, 9, 7, 8];
    for a = 1 : 5
        for b = 1 : 5
            subplot(5, 5, (a-1)*5+b);
            classifier_plot = squeeze(Accuracy_WindowSwitch(plotting_order(a),plotting_order(b)-5,:,:));   
            shuffled_plot = squeeze(Accuracy_WindowSwitch_shuffled(plotting_order(a),plotting_order(b)-5,:,:));
            curve1 = stdshade(classifier_plot',0.4,'b');
            hold on;
            curve2 = stdshade(shuffled_plot',0.4,'r');
            
            
            ylim([30 100]);
            line([15 15;30 30]', [30 100;30 100]','Color','k','LineStyle','--');
            xticks([0 15 30 45])
            xticklabels({'-15','0','15','30'})
            set(gca,'box','off')
            set(gca,'tickdir','out')
            
            titles = {'Baseline', 'Early Stim', 'Late Stim', 'Delay', 'Response'};
            if a == 1
                TITLE = ['Data from ', titles{b}, ' Inactivation'];
                title(TITLE);
                
                if b == 5
                    legend([curve1, curve2], 'Parietal', 'Shuffled');
                end
            end
            
            if b == 1
                y_label = [titles{a}, ' Classifier'];
                ylabel(y_label, 'fontweight', 'bold');
            end
            
        end
    end
    
    
else
    disp('Can not find this area!');
end

hold off


end



%%
function [Accuracy_FPSwitch, Accuracy_FPSwitch_shuffled] = SwitchFP(Accuracy_FPSwitch, Accuracy_FPSwitch_shuffled, ...
    x, b, c, classes, ClassifierModel, ShuffleModel, timespan, coordinate, labelNum)

% Accuracy_FPSwitch = nan(10, 45, 10) --> (2 areas * 5 types) * 45 frames * 10 repeats

if x <= 5
    merged = [classes{12}; classes{12-x}];
elseif x > 5
    merged = [classes{1}; classes{12-x}];
end

merged = merged(randperm(size(merged,1)), :);
this_group_info = merged(:, end);

merged(:,end) = [];
merged = reshape(merged, [size(merged, 1), timespan, coordinate, labelNum]);

ttt = unique(this_group_info);
ttt = sort(abs(ttt));


merged_Baseline = merged(:, 1:45, :, :);    % Used for testing switched classifiers
merged_EarlyStim = merged(:, 15:59, :, :);
merged_LateStim = merged(:, 30:74, :, :);
merged_Delay = merged(:, 45:89, :, :);
merged_Response = merged(:, 60:104, :, :);

if ttt(1) == 1
    merged = merged_EarlyStim;
elseif ttt(1) == 2
    merged = merged_Delay;
elseif ttt(1) == 3
    merged = merged_Response;
elseif ttt(1) == 4
    merged = merged_LateStim;
elseif ttt(1) == 5
    merged = merged_Baseline;
end


this_frame = reshape(merged(:,b,:,:), [size(merged, 1), coordinate*labelNum]);
% We have to change the group label to match ClassNames of classifier
this_group_info = this_group_info .* (-1);


% Calculating the loss of linear model. Please notice ClassifierModel is a ClassificationPartitionedLinear object

L_experiment = TenFoldLoss(ClassifierModel, this_frame, this_group_info);
L_control = TenFoldLoss(ShuffleModel, this_frame, this_group_info);


Accuracy_FPSwitch(x, b, c) = (1 - L_experiment)*100;
Accuracy_FPSwitch_shuffled(x, b, c) = (1 - L_control)*100;

end



%%
function FPSwitchPlotting(Accuracy_FPSwitch, Accuracy_FPSwitch_shuffled)

% Optotype = 1 starts together with the stimulus. Usually it covers the first 0.5 s of the stimulus but depending on the session, it might stay on until the end of the delay period.
% Optotype = 2 starts at the end of the stimulus period (begin of delay period)
% Optotype = 3 starts at the end of the delay period (begin of response period)
% Optotype = 4 starts in the later part of the stimulus period and ends with the stimulus
% Optotype = 5 starts 0.5s before the stimulus and ends with stimulus onset
% rawdata.optoDur to check how long the stimulation lasted. In sessions where 5 types were used, it should always be 0.5s
figure;

plotting_order = [5, 1, 4, 2, 3];
for a = 1 : 5
    subplot(2, 5, a);
    classifier_plot = squeeze(Accuracy_FPSwitch(plotting_order(a),:,:));
    shuffled_plot = squeeze(Accuracy_FPSwitch_shuffled(plotting_order(a),:,:));
    curve1 = stdshade(classifier_plot',0.4,'b');
    hold on;
    curve2 = stdshade(shuffled_plot',0.4,'r');
    
    
    ylim([30 100]);
    line([15 15;30 30]', [30 100;30 100]','Color','k','LineStyle','--');
    xticks([0 15 30 45])
    xticklabels({'-15','0','15','30'})
    set(gca,'box','off')
    set(gca,'tickdir','out')
    
    titles = {'Baseline', 'Early Stim', 'Late Stim', 'Delay', 'Response'};
    TITLE = [titles{a}, ' Inactivation'];
    title(TITLE);
    
    if a == 1
        ylabel('Frontal Classifier', 'fontweight', 'bold');
    elseif a == 5
        legend([curve1, curve2], 'Parietal Data', 'Shuffled');
    end
    
end



plotting_order = [10, 6, 9, 7, 8];
for a = 1 : 5
    subplot(2, 5, 5+a);
    classifier_plot = squeeze(Accuracy_FPSwitch(plotting_order(a),:,:));
    shuffled_plot = squeeze(Accuracy_FPSwitch_shuffled(plotting_order(a),:,:));
    curve1 = stdshade(classifier_plot',0.4,'b');
    hold on;
    curve2 = stdshade(shuffled_plot',0.4,'r');
    
    
    ylim([30 100]);
    line([15 15;30 30]', [30 100;30 100]','Color','k','LineStyle','--');
    xticks([0 15 30 45])
    xticklabels({'-15','0','15','30'})
    set(gca,'box','off')
    set(gca,'tickdir','out')
    
    
    if a == 1
        ylabel('Parietal Classifier', 'fontweight', 'bold');
    elseif a == 5
        legend([curve1, curve2], 'Frontal Data', 'Shuffled');
    end
    
end


hold off

end
