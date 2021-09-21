%% This code is used to investigate how the peformance of linear classifier changes with time 
% and which body part contributes to the classfying result most.

function [] = LinearClassifierPlus(overall_PCAmatrix, raw_data, plotting_idx)

global mouse_name  
mousename = mouse_name;
global Laterl_labels Bottom_labels

[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);
overall_PCAmatrix_backup = overall_PCAmatrix;


%% 1st, How does the peformance of linear classifier change with time?
if plotting_idx(1) == 1
    
    dividemode_List = {'outcome', 'responseside', 'formeroutcome', 'formerresponseside'};   % Predictiving these 4 conditions
    Accuracy_data = nan(length(dividemode_List), timespan, 10); % 10 times repeated cross validation
    Accuracy_shuffled = nan(length(dividemode_List), timespan, 10);
    
    for n = 1 : length(dividemode_List)
        
        overall_PCAmatrix = reshape(overall_PCAmatrix_backup, [trialNum, timespan*coordinate*labelNum]);
        overall_PCAmatrix = GroupData_Mouse(overall_PCAmatrix, dividemode_List{n}, raw_data);
        
        if length(unique(overall_PCAmatrix(:,end))) > 2
            % fprintf('This grouping result has MORE than 2 classes! Classifier could not process this! \n');
            overall_PCAmatrix(overall_PCAmatrix(:,end)==0,:) = [];
            % fprintf('The class 0 is removed. \n');
            if length(unique(overall_PCAmatrix(:,end))) > 2
                fprintf(2, 'Still more than 2 classes! This analysis is skipped. \n');
                return
            end
        end
        
        
        % Note: the sample numbers should be balanced
        group_info = overall_PCAmatrix(:, end);
        a = unique(group_info);
        sample_num = min(length(group_info(group_info==a(1))), length(group_info(group_info==a(2))));
        
        for c = 1 : size(Accuracy_data, 3)
            idx_1 = find(group_info == a(1));
            idx_2 = find(group_info == a(2));
            
            msize = numel(idx_1);
            ttt = randperm(msize);
            idx_1 = idx_1(ttt(1:sample_num));
            msize = numel(idx_2);
            ttt = randperm(msize);
            idx_2 = idx_2(ttt(1:sample_num));
            clear msize ttt
            
            class_1 = overall_PCAmatrix(idx_1, :);
            class_2 = overall_PCAmatrix(idx_2, :);
            
            merged = [class_1; class_2];
            merged = merged(randperm(size(merged,1)), :);
            this_group_info = merged(:, end);
            merged(:,end) = [];
            merged = reshape(merged, [size(merged, 1), timespan, coordinate, labelNum]);
            clear class_1 class_2 idx_1 idx_2 
            
            
            for b = 1 : timespan
                this_frame = reshape(merged(:,b,:,:), [size(merged, 1), coordinate*labelNum]);
                
                % for c = 1 : size(Accuracy_data, 3)
                ClassifierModel = fitclinear(this_frame', this_group_info, 'ObservationsIn', 'columns', 'Crossval', 'on');
                %prediction = kfoldPredict(ClassifierModel);
                L_experiment = kfoldLoss(ClassifierModel);
                ShuffleModel = fitclinear(this_frame', this_group_info(randperm(length(this_group_info))), 'ObservationsIn', 'columns', 'Crossval', 'on');
                %prediction_shuffle = kfoldPredict(ShuffleModel);
                L_control = kfoldLoss(ShuffleModel);
                
                Accuracy_data(n, b, c) = (1 - L_experiment)*100;
                Accuracy_shuffled(n, b, c) = (1 - L_control)*100;
                
                clear ClassifierModel ShuffleModel
                % end
                
            end
            
        end
        clear group_info a sample_num overall_PCAmatrix
    end

    clear n i g b c merged this_frame
    
    
    figure;
    for a = 1 : size(Accuracy_data,1)
        subplot(2, ceil(size(Accuracy_data,1)/2), a);
        yyy = squeeze(Accuracy_data(a,:,:));
        zzz = squeeze(Accuracy_shuffled(a,:,:));
        curve1 = stdshade(yyy',0.4,'b');
        hold on;
        curve2 = stdshade(zzz',0.4,'r');
        
        ylim([45 100]);
        line([15 15;45 45;60 60]', [45 100;45 100;45 100]','Color','k');
        legend([curve1, curve2], 'Labeled', 'Shuffled');
        xlabel('Frames');
        ylabel('Accuracy(%)');
        TITLE = ['Linear Classifier at each Frame, ', mousename, ', ', dividemode_List{a}];
        title(TITLE);
    end

    hold off
    
end



%% 2nd, How does each body part contribute to the classfying?
if plotting_idx(2) == 1
    dividemode_List = {'outcome', 'responseside'};  % Predictiving these 2 conditions
    Predic_accuracy = nan(length(dividemode_List), timespan, labelNum);
    
    for n = 1 : length(dividemode_List) 
        
        overall_PCAmatrix = reshape(overall_PCAmatrix_backup, [trialNum, timespan*coordinate*labelNum]);
        overall_PCAmatrix = GroupData_Mouse(overall_PCAmatrix, dividemode_List{n}, raw_data);
        
        if length(unique(overall_PCAmatrix(:,end))) > 2
            % fprintf('This grouping result has MORE than 2 classes! Classifier could not process this! \n');
            overall_PCAmatrix(overall_PCAmatrix(:,end)==0,:) = [];
            % fprintf('The class 0 is removed. \n');
            if length(unique(overall_PCAmatrix(:,end))) > 2
                fprintf(2, 'Still more than 2 classes! This analysis is skipped. \n');
                return
            end
        end
        
        
        % Note: the sample numbers should be balanced
        group_info = overall_PCAmatrix(:, end);
        a = unique(group_info);
        sample_num = min(length(group_info(group_info==a(1))), length(group_info(group_info==a(2))));
        idx_1 = find(group_info == a(1));
        idx_2 = find(group_info == a(2));
        
        msize = numel(idx_1);
        ttt = randperm(msize);
        idx_1 = idx_1(ttt(1:sample_num));
        msize = numel(idx_2);
        ttt = randperm(msize);
        idx_2 = idx_2(ttt(1:sample_num));
        clear msize ttt a
        
        class_1 = overall_PCAmatrix(idx_1, :);
        class_2 = overall_PCAmatrix(idx_2, :);
        
        merged = [class_1; class_2];
        merged = merged(randperm(size(merged,1)), :);
        group_info = merged(:, end);
        merged(:,end) = [];
        merged = reshape(merged, [size(merged, 1), timespan, coordinate, labelNum]);
        clear class_1 class_2 idx_1 idx_2 overall_PCAmatrix sample_num
        
        
        for b = 1 : timespan
            this_frame = reshape(merged(:,b,:,:), [size(merged, 1), coordinate, labelNum]);
            
            for d = 1 : labelNum
                this_label = squeeze(this_frame(:,:,d));
                ClassifierModel = fitclinear(this_label', group_info, 'ObservationsIn', 'columns', 'Crossval', 'on', 'Learner', 'svm');
                L_experiment = kfoldLoss(ClassifierModel);
                % prediction = kfoldPredict(ClassifierModel);
                ShuffleModel = fitclinear(this_label', group_info(randperm(length(group_info))), 'ObservationsIn', 'columns', 'Crossval', 'on', 'Learner', 'svm');
                L_control = kfoldLoss(ShuffleModel);
                % prediction_shuffle = kfoldPredict(ShuffleModel);
                
                Predic_accuracy(n, b, d) = (L_control - L_experiment)*100;
                clear ClassifierModel ShuffleModel
            end
        end
        
    end
    
    clear n i g b c d merged this_frame
    
    
    labels = [Laterl_labels, Bottom_labels];
    
    figure;
    plot(Predic_accuracy(1,:,1), '.-' , 'LineWidth', 1.5);
    hold on
    for a = 2 : labelNum
        plot(Predic_accuracy(1,:,a), '.-' , 'LineWidth', 1.5);
    end
    legend(labels);
    xlabel('Frames');
    ylabel('? Accuracy(%)');
    TITLE = ['Linear Classifier at each Frame, ', mousename, ', ', dividemode_List{1}];
    title(TITLE);
    hold off
    
    
    figure;
    plot(Predic_accuracy(2,:,1), '.-' , 'LineWidth', 1.5);
    hold on
    for a = 2 : labelNum
        plot(Predic_accuracy(2,:,a), '.-' , 'LineWidth', 1.5);
    end
    legend(labels);
    xlabel('Frames');
    ylabel('? Accuracy(%)');
    TITLE = ['Linear Classifier at each Frame, ', mousename, ', ', dividemode_List{2}];
    title(TITLE);
    hold off
    
    
    figure;
    for a = 1 : size(Predic_accuracy,1)
        test_1 = squeeze(Predic_accuracy(a,40:60,:));
        average_1 = mean(test_1,1);
        std_1 = std(test_1, 1);

        subplot(2, ceil(size(Predic_accuracy,1)/2), a);
        bar(categorical(labels), average_1);
        hold on
        er = errorbar(categorical(labels), average_1 , -std_1, std_1);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        ylabel('? Accuracy(%)');
        TITLE = ['Linear Classifier of each Label, ', mousename, ', ', dividemode_List{a}, ', Frame 40~60'];
        title(TITLE);
    end
    
    hold off
    clear test_1 average_1 std_1 TITLE
end



%% 3rd, How do different opto stimulations affect movement pattern differently? Is it correlated with performance change?
if plotting_idx(3) == 1
    
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
        b =  [b, length(group_info(group_info == unique_labels(nnn)))];
    end
    sample_num = min(b);
    clear nnn b
    
    
    Accuracy_data = nan(10, 45, 10);   % (2 areas * 5 types) * 45 frames * 10 repeats
    Accuracy_shuffled = nan(10, 45, 10);
    Classifier_Weight = nan(10, 45, 10, coordinate, labelNum);
    
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
            
            merged_Baseline = merged(:, 1:45, :, :);    % Used for testing switched classifiers
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
                           
                ClassifierModel = fitclinear(this_frame', this_group_info, 'ObservationsIn', 'columns', 'Crossval', 'on');  
                % Please notice, using cross-validation would make ClassifierModel a ClassificationPartitionedLinear object,
                % which is a collection of cross-validated ClassificationLinear objects.
                % In this case, 'predict' function is only appliable for the saved ClassificationLinear objects.  
                % These ClassificationLinear objects are kept in ClassifierModel.Trained
                L_experiment = kfoldLoss(ClassifierModel);
                ShuffleModel = fitclinear(this_frame', this_group_info(randperm(length(this_group_info))), 'ObservationsIn', 'columns', 'Crossval', 'on');
                L_control = kfoldLoss(ShuffleModel);
                
                Accuracy_data(x, b, c) = (1 - L_experiment)*100;
                Accuracy_shuffled(x, b, c) = (1 - L_control)*100;

                
                for_weight = [];
                for t = 1 : 10  % 10-fold validation, so t is 1 to 10
                    for_weight = [for_weight, ClassifierModel.Trained{t,1}.Beta];
                end
                for_weight = mean(for_weight, 2);
                for_weight = reshape(for_weight, [coordinate, labelNum]);
                Classifier_Weight(x, b, c, :, :) = for_weight;
                
                clear ClassifierModel ShuffleModel L_control L_experiment for_weight t       
                
            end
            
        end
        
    end
    
    clear x ttt b c merged this_frame this_group_info idx 
       
    
    % Optotype = 1 starts together with the stimulus. Usually it covers the first 0.5 s of the stimulus but depending on the session, it might stay on until the end of the delay period.
    % Optotype = 2 starts at the end of the stimulus period (begin of delay period)
    % Optotype = 3 starts at the end of the delay period (begin of response period)
    % Optotype = 4 starts in the later part of the stimulus period and ends with the stimulus
    % Optotype = 5 starts 0.5s before the stimulus and ends with stimulus onset
    % rawdata.optoDur to check how long the stimulation lasted. In sessions where 5 types were used, it should always be 0.5s  
    figure;
    for a = 1 : 5
        subplot(2, ceil(size(Accuracy_data,1)/4), a);
        yyy_F = squeeze(Accuracy_data(a,:,:));    % frontal areas
        zzz_F = squeeze(Accuracy_shuffled(a,:,:));
        curve1 = stdshade(yyy_F',0.4,'b');
        hold on;
        curve2 = stdshade(zzz_F',0.4,'r');
        
        yyy_P = squeeze(Accuracy_data(11-a,:,:));    % parietal areas
        zzz_P = squeeze(Accuracy_shuffled(11-a,:,:));
        curve3 = stdshade(yyy_P',0.4,'c');
        curve4 = stdshade(zzz_P',0.4,'m');
        
        ylim([30 100]);
        line([15 15;30 30]', [30 100;30 100]','Color','k');
        xticks([0 15 30 45])
        xticklabels({'-15','0','15','30'})
        legend([curve1, curve2, curve3, curve4], 'Frontal Labeled', 'Frontal Shuffled', 'Parietal Labeled', 'Parietal Shuffled');
        xlabel('Frames to Stimulation On');
        ylabel('Accuracy(%)');
        TITLE = ['Linear Classifier at each Frame, ', mousename, ', Opto Type', num2str(a)];
        title(TITLE);
    end

    clear a yyy_F zzz_F curve1 curve2 yyy_P zzz_P curve3 curve4 TITLE overall_PCAmatrix
 
    
    % ---- Then compare the affect on movement pattern and performance ----
    Outcome = raw_data.Rewarded;
    if length(Outcome) ~= length(group_info)
        fprintf(2, 'The numbers of raw data records and grouping results are unequal! \n');
        return
    end
    
    correctRate = zeros(1,11);
    unique_labels = unique_labels([1,2,11,6,7,3,10,5,8,4,9]); % changing the order for bar graph
    for a = 1 : 11
        if a == 1
            num_trial = length(find(abs(group_info) == 100));   % we need both two types of control trials here (-100 & 100)
            num_correct = sum(Outcome(abs(group_info) == 100));
        else
            num_trial = length(find(group_info == unique_labels(a)));
            num_correct = sum(Outcome(group_info == unique_labels(a)));            
        end
        correctRate(a) = 100 * num_correct / num_trial;
    end
    
    
    x_label = {'Baseline', 'StimulusOn', 'StimulusLater', 'Delay', 'SpoutsIn'};
    subplot(2,3,6);
    plot([1,2,3,4,5], correctRate(2:2:10), 'b-o', 'LineWidth', 3);
    hold on
    plot([1,2,3,4,5], correctRate(3:2:11), 'c-o', 'LineWidth', 3);
    line([1 5], [correctRate(1) correctRate(1)], 'Color','black','LineStyle','--'); 
    set(gca,'xtick',[1:5],'xticklabel',x_label);
    ylim([50 100]);
    legend({'Frontal', 'Parietal'});
    ylabel('Correct Rate (%)');
    title(['Correct Rate of Opto Stimulation Trials, ', mousename]);
    hold off
    
    clear a x_label Outcome correctRate num_trial num_correct
    
    
    % ---------------- The weights of different body parts ----------------
    Classifier_Weight = Classifier_Weight(:, 16:30, :, :, :);
    Classifier_Weight = reshape(Classifier_Weight, 10, [], labelNum);
    Classifier_Weight = permute(Classifier_Weight,[3, 1, 2]);
    
    Classifier_Weight_F = reshape(Classifier_Weight(:, 1:5, :), 28, []);
    Classifier_Weight_P = reshape(Classifier_Weight(:, 6:10, :), 28, []);
    
    F_std = std(Classifier_Weight_F,0,2);
    P_std = std(Classifier_Weight_P,0,2);
    
    Classifier_Weight_F = mean(Classifier_Weight_F, 2);
    Classifier_Weight_P = mean(Classifier_Weight_P, 2);
    
    labels = [Laterl_labels, Bottom_labels];
    
    
    figure;
    p1 = plot(1:28, Classifier_Weight_F, 'b-o', 'LineWidth', 1.5);
    hold on
    p2 = plot(1:28, Classifier_Weight_P, 'c-o', 'LineWidth', 1.5);
     
    ylabel('Weight');
    title(['The Classifier Weights of Body Parts, ', mousename]);
    
    errorbar(1:28, Classifier_Weight_F , -F_std, F_std, 'Color', 'b', 'LineStyle', 'none');
    errorbar(1:28, Classifier_Weight_P , -P_std, P_std, 'Color', 'c', 'LineStyle', 'none');
    line([1 28], [0 0], 'Color','black','LineStyle','--'); 
    set(gca,'xtick',[1:28],'xticklabel',labels);
    legend([p1, p2], 'Frontal', 'Parietal');
    
    set(gca,'box','off')
    set(gca,'tickdir','out')
    
    hold off
    clear p1 p2 F_std P_std Classifier_Weight_F Classifier_Weight_P
    
end


end
