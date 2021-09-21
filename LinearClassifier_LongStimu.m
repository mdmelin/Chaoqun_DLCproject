%% This code is written to compare the control & effective stimulation trials of Fez7. 
% Control Fez7 trials (on Apr 25th and 26th) only have 1.5s stimulation. Thus, we need to rewrite the linear classifier codes.

function LinearClassifier_LongStimu(overall_PCAmatrix, raw_data, plotting_idx)


global mouse_name  
mousename = mouse_name;
global Laterl_labels Bottom_labels

[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);
overall_PCAmatrix_backup = overall_PCAmatrix;




%% 1st, How do different opto stimulations affect movement pattern differently? Is it correlated with performance change?
if plotting_idx(1) == 1
    
    overall_PCAmatrix = reshape(overall_PCAmatrix_backup, [trialNum, timespan*coordinate*labelNum]);
    overall_PCAmatrix = GroupData_Mouse(overall_PCAmatrix, 'optotype_classifier', raw_data);
    
    % Note: the sample numbers should be balanced
    group_info = overall_PCAmatrix(:, end);
    unique_labels = unique(group_info);
    %unique_labels = [0; unique_labels];
    %unique_labels(3) = [];  % After this step unique_labels will be [0 -1 1]
    
    fprintf(2, ['Please notice that there are only two types of stimulation in ', mousename, ' 1.5s stimulation sessions! \n']);

    
    b = [];
    for nnn = 1 : length(unique_labels)
        b =  [b, length(group_info(group_info == unique_labels(nnn)))];
    end
    sample_num = min(b);
    clear nnn b

    
    Accuracy_data = nan(90, 30);   % 90 frames (1.5s stimulation) * 30 repeats
    Accuracy_shuffled = nan(90, 30);
    Classifier_Weight = nan(90, 30, coordinate, labelNum);
    for c = 1 : size(Accuracy_data, 2)
        idx = {};
        classes = {};
        for n = 1 : 2
            idx{n} = find(group_info == unique_labels(n));
            
            msize = numel(idx{n});
            ttt = randperm(msize);
            idx{n} = idx{n}(ttt(1:sample_num));
            
            classes{n} = overall_PCAmatrix(idx{n}, :);
        end
        
        clear msize ttt n idx
        
        
        merged = [classes{1}; classes{2}];
        merged = merged(randperm(size(merged,1)), :);
        this_group_info = merged(:, end);
        merged(:,end) = [];
        
        merged = reshape(merged, [size(merged, 1), timespan, coordinate, labelNum]);
        merged = merged(:, 1:90, :, :);
        
        
        for b = 1 : size(Accuracy_data,1)
            this_frame = reshape(merged(:,b,:,:), [size(merged, 1), coordinate*labelNum]);
            
            
            ClassifierModel = fitclinear(this_frame', this_group_info, 'ObservationsIn', 'columns', 'Crossval', 'on');
            L_experiment = kfoldLoss(ClassifierModel);
            ShuffleModel = fitclinear(this_frame', this_group_info(randperm(length(this_group_info))), 'ObservationsIn', 'columns', 'Crossval', 'on');
            L_control = kfoldLoss(ShuffleModel);
            
            Accuracy_data(b, c) = (1 - L_experiment)*100;
            Accuracy_shuffled(b, c) = (1 - L_control)*100;
            
            for_weight = [];
            for t = 1 : 10  % 10-fold validation, so t is 1 to 10
                for_weight = [for_weight, ClassifierModel.Trained{t,1}.Beta];
            end
            for_weight = mean(for_weight, 2);
            for_weight = reshape(for_weight, [coordinate, labelNum]);
            Classifier_Weight(b, c, :, :) = for_weight;
            
            clear ClassifierModel ShuffleModel L_control L_experiment for_weight t
            
        end
          
        
    end
    
    clear b c merged this_frame this_group_info idx
    
    
    
    
    figure;

    curve1 = stdshade(Accuracy_data',0.4,'b');
    hold on;
    curve2 = stdshade(Accuracy_shuffled',0.4,'r');

  
    ylim([30 100]);
%     line([15 15;60 60]', [30 100;30 100]','Color','k');
    line([30 30;75 75]', [30 100;30 100]','Color','k');
%     xticks([0 15 30 45 60 75]);
%     xticklabels({'-15','0','15','30','45','60'});
    xticks([0 15 30 45 60 75 90]);
    xticklabels({'-30','-15','0','15','30','45','60'});
    if ismember(-1,unique_labels)
        legend([curve1, curve2], 'Frontal Labeled', 'Frontal Shuffled');
    elseif ismember(1,unique_labels)
        legend([curve1, curve2], 'Parietal Labeled', 'Parietal Shuffled');
    end
    xlabel('Frames to Stimulation On');
    ylabel('Accuracy(%)');
    TITLE = ['Linear Classifier at each Frame, ', mousename, ', 1.5s Stimulation'];
    title(TITLE);
    set(gca,'box','off');
    set(gca,'tickdir','out');

    clear curve1 curve2 TITLE overall_PCAmatrix
 
    
    % ---- Then compare the affect on movement pattern and performance ----
%     Outcome = raw_data.Rewarded;
%     if length(Outcome) ~= length(group_info)
%         fprintf(2, 'The numbers of raw data records and grouping results are unequal! \n');
%         return
%     end
%     
%     correctRate = zeros(1,3);
%     for a = 1 : 3
%         num_trial = length(find(group_info == unique_labels(a)));
%         num_correct = sum(Outcome(group_info == unique_labels(a)));
%         correctRate(a) = 100 * num_correct / num_trial;
%     end
%     
%     
%     x_label = {'Control', 'Frontal', 'Parietal'};
%     figure;
%     plot([1,2,3], correctRate, 'b-o', 'LineWidth', 3);
%     line([1 3], [correctRate(1) correctRate(1)], 'Color','black','LineStyle','--'); 
%     set(gca,'xtick',[1:3],'xticklabel',x_label);
%     ylim([50 100]);
%     ylabel('Correct Rate (%)');
%     title(['Correct Rate of Opto Stimulation Trials, ', mousename, ', 1.5s Stimulation']);
%     hold off
%     
%     clear a x_label Outcome correctRate num_trial num_correct
    
    
    % ---------------- The weights of different body parts ----------------
    Classifier_Weight = reshape(Classifier_Weight,size(Classifier_Weight,1), [], labelNum);
    std_time = squeeze(std(Classifier_Weight,0,2));
    Classifier_Weight = squeeze(mean(Classifier_Weight,2));
    
    labels = [Laterl_labels, Bottom_labels];
    
    figure;
    surf(Classifier_Weight);
    colorbar;
    set(gca,'xtick',[1:28],'xticklabel',labels);
    yticks([0 15 30 45 60 75 90]);
    yticklabels({'-30','-15','0','15','30','45','60'});
    ylabel('Time');
    zlabel('Weight');
    
    if ismember(-1,unique_labels)
        title(['The Classifier Weights of Body Parts, ', mousename, ', 1.5s Stimulation, Frontal']);
    elseif ismember(1,unique_labels)
        title(['The Classifier Weights of Body Parts, ', mousename, ', 1.5s Stimulation, Parietal']);
    end
    
    rotate3d on
    hold off

    
    
    figure;
    surf(std_time);
    colorbar;
    set(gca,'xtick',[1:28],'xticklabel',labels);
    yticks([0 15 30 45 60 75 90]);
    yticklabels({'-30','-15','0','15','30','45','60'});
    ylabel('Time');
    zlabel('Standard Deviation');
    
    if ismember(-1,unique_labels)
        title(['The Std of Classifier Weights, ', mousename, ', 1.5s Stimulation, Frontal']);
    elseif ismember(1,unique_labels)
        title(['The Std of Classifier Weights, ', mousename, ', 1.5s Stimulation, Parietal']);
    end
    
    rotate3d on
    hold off

    
end


end
