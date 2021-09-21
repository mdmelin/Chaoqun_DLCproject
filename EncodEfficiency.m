%% This code is designed to look at the potential correlation between
% condition-indepdent variance and cortex encoding efficiency
% In this code, we look at V1 activity in the stimulus period of visual trials,
% A1 activity in the stimulus period of auditory trials, and motor cortex
% activity in the response period of all trials.
%% Only correct trials are used.


function [] = EncodEfficiency(raw_data, V1_activity, M2_activity, Group_LowVariance, Group_HighVariance, plot_index)

if isempty(plot_index)
    return;
end

if isempty(V1_activity) || isempty(M2_activity)
    disp('No imaging data was found! Can''t run function EncodEfficiency.');
    return;
end

global mouse_name  
mousename = mouse_name;

%% 1. Only getting correct trials
outcome_highV = raw_data.Rewarded(Group_HighVariance);  % Group_HighVariance & Group_LowVariance don't contain any non-response trials.
outcome_lowV = raw_data.Rewarded(Group_LowVariance);


sample_highV = Group_HighVariance(outcome_highV == 1);  % only using correct trials
sample_lowV = Group_LowVariance(outcome_lowV == 1);
clear outcome_highV outcome_lowV



%% 2. Applying classifier on V1, distinguishing stimulus.
if plot_index(1) == 1
    
    sample_highV_LStim = sample_highV(raw_data.CorrectSide(sample_highV) == 1);
    sample_highV_RStim = sample_highV(raw_data.CorrectSide(sample_highV) == 2);
    sample_lowV_LStim = sample_lowV(raw_data.CorrectSide(sample_lowV) == 1);
    sample_lowV_RStim = sample_lowV(raw_data.CorrectSide(sample_lowV) == 2);
    % for balancing classifier sample numbers
    sample_num = min([length(sample_highV_LStim), length(sample_highV_RStim), length(sample_lowV_LStim), length(sample_lowV_RStim)]);
    
    
%     V1_activity(:,:,1:44,:) = [];   % stimulus period is only from frame 45 to frame 60
%     V1_activity(:,:,16:end,:) = [];
    
    % highV group first
    Accuracy_data_highV = nan(size(V1_activity,3), 10); % all frames, 30 times repeated cross validation
    Accuracy_shuffled_highV = nan(size(V1_activity,3), 10);
    
    for t = 1 : size(Accuracy_data_highV, 2)
        msize = numel(sample_highV_LStim);
        idx_highV_LStim = randperm(msize);
        idx_highV_LStim = sample_highV_LStim(idx_highV_LStim(1:sample_num));
        
        msize = numel(sample_highV_RStim);
        idx_highV_RStim = randperm(msize);
        idx_highV_RStim = sample_highV_RStim(idx_highV_RStim(1:sample_num));
        
        idx_highV_LR = [idx_highV_LStim, idx_highV_RStim];
        keys = raw_data.CorrectSide(idx_highV_LR);
        
        V1_activity_highV = V1_activity(:,:,:,idx_highV_LR);
        
        
        for frame = 1 : size(V1_activity_highV,3)
            thisFrame = reshape(squeeze(V1_activity_highV(:,:,frame,:)), [], sample_num*2);
            
            ClassifierModel = fitclinear(thisFrame, keys, 'ObservationsIn', 'columns', 'Crossval', 'on');
            Loss_experiment = kfoldLoss(ClassifierModel);
            ShuffleModel = fitclinear(thisFrame, keys(randperm(length(keys))), 'ObservationsIn', 'columns', 'Crossval', 'on');
            Loss_control = kfoldLoss(ShuffleModel);
            
            Accuracy_data_highV(frame, t) = (1 - Loss_experiment)*100;
            Accuracy_shuffled_highV(frame, t) = (1 - Loss_control)*100;
            
            
            clear ClassifierModel ShuffleModel thisFrame
        end
        
    end
    
    
    % Then lowV group
    Accuracy_data_lowV = nan(size(V1_activity,3), 10); % all frames, 10 times repeated cross validation
    Accuracy_shuffled_lowV = nan(size(V1_activity,3), 10);
    
    for t = 1 : size(Accuracy_data_lowV, 2)
        msize = numel(sample_lowV_LStim);
        idx_lowV_LStim = randperm(msize);
        idx_lowV_LStim = sample_lowV_LStim(idx_lowV_LStim(1:sample_num));
        
        msize = numel(sample_lowV_RStim);
        idx_lowV_RStim = randperm(msize);
        idx_lowV_RStim = sample_lowV_RStim(idx_lowV_RStim(1:sample_num));
        
        idx_lowV_LR = [idx_lowV_LStim, idx_lowV_RStim];
        keys = raw_data.CorrectSide(idx_lowV_LR);
        
        V1_activity_lowV = V1_activity(:,:,:,idx_lowV_LR);
        
        
        for frame = 1 : size(V1_activity_lowV,3)
            thisFrame = reshape(squeeze(V1_activity_lowV(:,:,frame,:)), [], sample_num*2);
            
            ClassifierModel = fitclinear(thisFrame, keys, 'ObservationsIn', 'columns', 'Crossval', 'on');
            Loss_experiment = kfoldLoss(ClassifierModel);
            ShuffleModel = fitclinear(thisFrame, keys(randperm(length(keys))), 'ObservationsIn', 'columns', 'Crossval', 'on');
            Loss_control = kfoldLoss(ShuffleModel);
            
            Accuracy_data_lowV(frame, t) = (1 - Loss_experiment)*100;
            Accuracy_shuffled_lowV(frame, t) = (1 - Loss_control)*100;
            
            
            
            clear ClassifierModel ShuffleModel thisFrame
        end
        
    end
    
    figure;
    curve1 = stdshade(Accuracy_data_highV',0.4,'b');
    ylim([30 100]);
    hold on;
    curve2 = stdshade(Accuracy_shuffled_highV',0.4,'r');
    curve3 = stdshade(Accuracy_data_lowV',0.4,'c');
    curve4 = stdshade(Accuracy_shuffled_lowV',0.4,'m');
    legend([curve1, curve2, curve3, curve4], 'highV', 'highV shuffled', 'lowV', 'lowV shuffled');
    xlabel('Frames from Stimulation On');
    ylabel('Accuracy(%)');
    TITLE = ['Linear Classifier for predicting the stimulus based on PPC, ', mousename];
    title(TITLE);
    set(gca,'box','off');
    set(gca,'tickdir','out');
    hold off
    
    clear curve1 curve2 curve3 curve4 TITLE
end

%% 3. Applying classifier on M2, distinguishing choice.
if plot_index(2) == 1
    
    sample_highV_LChoice = sample_highV(raw_data.ResponseSide(sample_highV) == 1);
    sample_highV_RChoice = sample_highV(raw_data.ResponseSide(sample_highV) == 2);
    sample_lowV_LChoice = sample_lowV(raw_data.ResponseSide(sample_lowV) == 1);
    sample_lowV_RChoice = sample_lowV(raw_data.ResponseSide(sample_lowV) == 2);
    % for balancing classifier sample numbers
    sample_num = min([length(sample_highV_LChoice), length(sample_highV_RChoice), length(sample_lowV_LChoice), length(sample_lowV_RChoice)]);
    
    
    % M2_activity(:,:,1:60,:) = [];   % response period is after frame 67
    
    % highV group first
    Accuracy_data_highV = nan(size(M2_activity,3), 10); % frames number, 30 times repeated cross validation
    Accuracy_shuffled_highV = nan(size(M2_activity,3), 10);
    
    for t = 1 : size(Accuracy_data_highV, 2)
        msize = numel(sample_highV_LChoice);
        idx_highV_LChoice = randperm(msize);
        idx_highV_LChoice = sample_highV_LChoice(idx_highV_LChoice(1:sample_num));
        
        msize = numel(sample_highV_RChoice);
        idx_highV_RChoice = randperm(msize);
        idx_highV_RChoice = sample_highV_RChoice(idx_highV_RChoice(1:sample_num));
        
        idx_highV_LR = [idx_highV_LChoice, idx_highV_RChoice];
        keys = raw_data.ResponseSide(idx_highV_LR);
        
        M2_activity_highV = M2_activity(:,:,:,idx_highV_LR);
        
        
        for frame = 1 : size(M2_activity,3)
            thisFrame = reshape(squeeze(M2_activity_highV(:,:,frame,:)), [], sample_num*2);
            
            ClassifierModel = fitclinear(thisFrame, keys, 'ObservationsIn', 'columns', 'Crossval', 'on');
            Loss_experiment = kfoldLoss(ClassifierModel);
            ShuffleModel = fitclinear(thisFrame, keys(randperm(length(keys))), 'ObservationsIn', 'columns', 'Crossval', 'on');
            Loss_control = kfoldLoss(ShuffleModel);
            
            Accuracy_data_highV(frame, t) = (1 - Loss_experiment)*100;
            Accuracy_shuffled_highV(frame, t) = (1 - Loss_control)*100;
            
            clear ClassifierModel ShuffleModel thisFrame
        end
        
    end
    
    
    % Then lowV group
    Accuracy_data_lowV = nan(size(M2_activity,3), 10); % frames number, 30 times repeated cross validation
    Accuracy_shuffled_lowV = nan(size(M2_activity,3), 10);
    
    for t = 1 : size(Accuracy_data_lowV, 2)
        msize = numel(sample_lowV_LChoice);
        idx_lowV_LChoice = randperm(msize);
        idx_lowV_LChoice = sample_lowV_LChoice(idx_lowV_LChoice(1:sample_num));
        
        msize = numel(sample_lowV_RChoice);
        idx_lowV_RChoice = randperm(msize);
        idx_lowV_RChoice = sample_lowV_RChoice(idx_lowV_RChoice(1:sample_num));
        
        idx_lowV_LR = [idx_lowV_LChoice, idx_lowV_RChoice];
        keys = raw_data.ResponseSide(idx_lowV_LR);
        
        M2_activity_lowV = M2_activity(:,:,:,idx_lowV_LR);
        
        
        for frame = 1 : size(M2_activity,3)
            thisFrame = reshape(squeeze(M2_activity_lowV(:,:,frame,:)), [], sample_num*2);
            
            ClassifierModel = fitclinear(thisFrame, keys, 'ObservationsIn', 'columns', 'Crossval', 'on');
            Loss_experiment = kfoldLoss(ClassifierModel);
            ShuffleModel = fitclinear(thisFrame, keys(randperm(length(keys))), 'ObservationsIn', 'columns', 'Crossval', 'on');
            Loss_control = kfoldLoss(ShuffleModel);
            
            Accuracy_data_lowV(frame, t) = (1 - Loss_experiment)*100;
            Accuracy_shuffled_lowV(frame, t) = (1 - Loss_control)*100;
            
            clear ClassifierModel ShuffleModel thisFrame
        end
        
    end
    
    figure;
    curve1 = stdshade(Accuracy_data_highV',0.4,'b');
    ylim([30 100]);
    hold on;
    curve2 = stdshade(Accuracy_shuffled_highV',0.4,'r');
    curve3 = stdshade(Accuracy_data_lowV',0.4,'c');
    curve4 = stdshade(Accuracy_shuffled_lowV',0.4,'m');
    legend([curve1, curve2, curve3, curve4], 'highV', 'highV shuffled', 'lowV', 'lowV shuffled');
    xlabel('Frames in Response Window');
    ylabel('Accuracy(%)');
    TITLE = ['Linear Classifier for predicting the choice based on M2, ', mousename];
    title(TITLE);
    set(gca,'box','off');
    set(gca,'tickdir','out');
    hold off
    
    clear curve1 curve2 curve3 curve4 TITLE
    
end

end