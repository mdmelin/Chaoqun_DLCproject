function [] = LinearClassifier(overall_PCAmatrix, divide_mode, raw_data)

[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);
overall_PCAmatrix = reshape(overall_PCAmatrix, [trialNum, timespan*coordinate*labelNum]);
clear timespan coordinate labelNum

overall_PCAmatrix = GroupData_Mouse(overall_PCAmatrix, divide_mode, raw_data);
if length(unique(overall_PCAmatrix(:,end))) > 2
    fprintf('This grouping result has MORE than 2 classes! Classifier could not process this! \n');
    overall_PCAmatrix(overall_PCAmatrix(:,end)==0,:) = [];
    fprintf('The class 0 is removed. \n');
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

overall_PCAmatrix = [class_1; class_2];
overall_PCAmatrix = overall_PCAmatrix(randperm(size(overall_PCAmatrix,1)), :);
group_info = overall_PCAmatrix(:, end);
overall_PCAmatrix(:,end) = [];
clear class_1 class_2 idx_1 idx_2


ClassifierModel = fitclinear(overall_PCAmatrix', group_info, 'ObservationsIn', 'columns', 'Crossval', 'on'); 
prediction = kfoldPredict(ClassifierModel);

ShuffleModel = fitclinear(overall_PCAmatrix', group_info(randperm(length(group_info))), 'ObservationsIn', 'columns', 'Crossval', 'on'); 
prediction_shuffle = kfoldPredict(ShuffleModel);



i = 0;
g = 0;
for a = 1 : length(group_info)
    if prediction(a) == group_info(a)
        i = i + 1;
    end
    if prediction_shuffle(a) == group_info(a)
        g = g + 1;
    end
end
i = i/length(group_info);
g = g/length(group_info);

figure;
subplot(1,2,1);
X = categorical({'Shuffled', 'Classifier'});
bar(X, [g, i]);
ylim([0 1]);
ylabel('Accuracy of Prediction');
title(['Predicting ', divide_mode, ' with Linear Classifier Based on Movement']);
clear i g


% To look at the classifier's performance with a broader view, we need the performance of the animal
L = 0;
R = 0;
L_correct = 0;
R_correct = 0;
for a = 1 : trialNum
    if raw_data.CorrectSide(a) == 1
        L = L + 1;
        if raw_data.ResponseSide(a) == 1
            L_correct = L_correct + 1;
        elseif isnan(raw_data.ResponseSide(a))
            L = L - 1;
        end
        
    elseif raw_data.CorrectSide(a) == 2
        R = R + 1;
        if raw_data.ResponseSide(a) == 2
            R_correct = R_correct + 1;
        elseif isnan(raw_data.ResponseSide(a))
            R = R - 1;
        end
        
    end
end

subplot(1,2,2);

X = categorical({'Left', 'Right'});
bar(X, [L_correct/L, R_correct/R]);
ylim([0 1]);
ylabel('Correct Rate');
title(['Animal Performance, No Response Rate: ' num2str(sum(raw_data.DidNotChoose)/trialNum)]);

hold off
clear L R L_correct R_correct
end