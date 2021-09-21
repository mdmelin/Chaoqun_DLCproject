%% In this function, we select equal correct and wrong trials from the behavior sessions of widefield imaging animals.
% Then we put these trials together to get a dataset. Then we further
% select a subset of these trials, which contains equal left/correct, left/wrong, right/correct, and right/wrong trials.
% Then the selected trials are used as samples to train linear classifer to decode stimulus signal and choice signal.

%% Please notice, due to the big size of imaging data, this function is designed to open the imaging data of each session 
% one by one. The needed trials are then extracted from the imaging matrix of each session.



function [] = EncodEfficiency_balancedRW(fPath, plot_index, region)

%% 1. Loading the index of the trials that we need
global Original_OrderIdx
original_OrderIdx = Original_OrderIdx;

idcs = strfind(fPath,'\');
parentdir = fPath(1:idcs(end-2));
clear idcs

global mouse_name  
mousename = mouse_name;



%% 2. Loading files
highTIV_all = [];
lowTIV_all = [];
for a = 1 : length(original_OrderIdx.SessionNames)
    
    this_session = [parentdir original_OrderIdx.Animal(:)' '_SpatialDisc_', original_OrderIdx.SessionNames{a}(:)' '\'];
    
    %% A) loading behavior .mat file
    this_session_rawdata = dir([this_session, original_OrderIdx.Animal(:)', '_SpatialDisc_*' 'frameTimes']);
    this_session_rawdata = [this_session_rawdata.folder '\' this_session_rawdata.name];
    
    raw_data_file = dir([this_session_rawdata '\' original_OrderIdx.Animal(:)' '_SpatialDisc_*' 'Session1.mat']);
    if isempty(raw_data_file)
        raw_data_file = dir([this_session_rawdata '\' original_OrderIdx.Animal(:)' '_SpatialDisc_*' 'Session2.mat']);
        if isempty(raw_data_file)
            raw_data_file = dir([this_session_rawdata '\' original_OrderIdx.Animal(:)' '_SpatialDisc_*' 'Session3.mat']);
        end
    end
    raw_data = load([raw_data_file.folder '\' raw_data_file.name]);
    raw_data = raw_data.SessionData;  
    clear this_session_rawdata raw_data_file
    
    %% B) loading imaging data
    this_session_Imaging = dir([this_session, original_OrderIdx.Animal(:)', '_SpatialDisc_*' 'Imaging']);
    this_session_Imaging = [this_session_Imaging.folder '\' this_session_Imaging.name '\'];
    
    load([this_session_Imaging, 'QR.mat'], 'nanIdx'); %index that was used to create AC
    load([this_session_Imaging, 'rsVc.mat'], 'Vc'); %downsampled version of Vc (15Hz instead of 30Hz). Stimulus at frame 45.
    load([this_session_Imaging, 'newAC_20_50.mat']);
    load([this_session_Imaging, 'rsVc.mat'], 'bTrials');   % for aligning behavioral rawdata raw_data and imaging data rsVc.
    
    [raw_data, ~, ~, ~] = selectBehaviorTrials_CY(raw_data, bTrials, [], [], []);
    nC = NaN(size(C,1), size(Vc,2),size(Vc,3), 'single'); %pre-allocate then fill with data
    nC(:, ~nanIdx) = C; %this has the same size as Vc (downsampled to 15Hz)
    
    %% C) select the region and trials we need
    region_activity = RegionSelect(regionMap, A, nC, region);
    if isempty(region_activity)
        fprintf(2,'This region does not exist in LocaNMF map! \n')
        return
    end
    
    [highTIV, lowTIV] = TrialSelect(region_activity, raw_data, bTrials, original_OrderIdx, a);
    clear region_activity
    
     
    
    if isempty(highTIV_all) && isempty(lowTIV_all)
        highTIV_all = highTIV;
        lowTIV_all = lowTIV;
        
    else
        highTIV_all.activity = cat(4, highTIV_all.activity, highTIV.activity);
        lowTIV_all.activity = cat(4, lowTIV_all.activity, lowTIV.activity);
        
        fn = fieldnames(highTIV_all.raw_data);
        for k=1:numel(fn)
            highTIV_all.raw_data.(fn{k}) = [highTIV_all.raw_data.(fn{k}), highTIV.raw_data.(fn{k})];
        end
        
        fn = fieldnames(lowTIV_all.raw_data);
        for k=1:numel(fn)
            lowTIV_all.raw_data.(fn{k}) = [lowTIV_all.raw_data.(fn{k}), lowTIV.raw_data.(fn{k})];
        end 
        clear fn k
    end
    
    clear highTIV lowTIV

end

clear regionMap Vc nC C bTrials areas A a lambdas nanIdx loc_thresh time_ests r2_fit 



%% 3. Getting the sample number
% To get a balanced training dataset, we need to make sure there
% are equal-number Left-Correct, Left-Error, Right-Correct, Right-Error trials.
sample_highV_LStim_C = intersect(find(highTIV_all.raw_data.CorrectSide == 1), find(highTIV_all.raw_data.Rewarded == 1));
sample_highV_LStim_E = intersect(find(highTIV_all.raw_data.CorrectSide == 1), find(highTIV_all.raw_data.Rewarded == 0));
sample_highV_RStim_C = intersect(find(highTIV_all.raw_data.CorrectSide == 2), find(highTIV_all.raw_data.Rewarded == 1));
sample_highV_RStim_E = intersect(find(highTIV_all.raw_data.CorrectSide == 2), find(highTIV_all.raw_data.Rewarded == 0));

sample_lowV_LStim_C = intersect(find(lowTIV_all.raw_data.CorrectSide == 1), find(lowTIV_all.raw_data.Rewarded == 1));
sample_lowV_LStim_E = intersect(find(lowTIV_all.raw_data.CorrectSide == 1), find(lowTIV_all.raw_data.Rewarded == 0));
sample_lowV_RStim_C = intersect(find(lowTIV_all.raw_data.CorrectSide == 2), find(lowTIV_all.raw_data.Rewarded == 1));
sample_lowV_RStim_E = intersect(find(lowTIV_all.raw_data.CorrectSide == 2), find(lowTIV_all.raw_data.Rewarded == 0));

% for balancing classifier sample numbers
sample_num = min([length(sample_highV_LStim_C), length(sample_highV_LStim_E), length(sample_highV_RStim_C), length(sample_highV_RStim_E), ...
    length(sample_lowV_LStim_C), length(sample_lowV_LStim_E), length(sample_lowV_RStim_C), length(sample_lowV_RStim_E)]);


    
%% 4. Training the classifiers
if sum(plot_index) == 1  

    % highV group first
    Accuracy_data_highV = nan(size(highTIV_all.activity,3), 10); % all frames, 10 times repeated cross validation
    Accuracy_shuffled_highV = nan(size(highTIV_all.activity,3), 10);
    
    for t = 1 : size(Accuracy_data_highV, 2)
        
        msize = numel(sample_highV_LStim_C); iidx_C = randperm(msize);
        iidx_C = sample_highV_LStim_C(iidx_C(1:sample_num));
        
        msize = numel(sample_highV_LStim_E); iidx_E = randperm(msize);
        iidx_E = sample_highV_LStim_E(iidx_E(1:sample_num));
        
        idx_highV_LStim = [iidx_C, iidx_E];
        
        
        msize = numel(sample_highV_RStim_C); iidx_C = randperm(msize);
        iidx_C = sample_highV_RStim_C(iidx_C(1:sample_num));
        
        msize = numel(sample_highV_RStim_E); iidx_E = randperm(msize);
        iidx_E = sample_highV_RStim_E(iidx_E(1:sample_num));
        
        idx_highV_RStim = [iidx_C, iidx_E];
        
        
        

        
        idx_highV_LR = [idx_highV_LStim, idx_highV_RStim];
        if plot_index(1) == 1
            keys = highTIV_all.raw_data.CorrectSide(idx_highV_LR);  % decoding stimulus
        elseif plot_index(2) == 1
            keys = highTIV_all.raw_data.ResponseSide(idx_highV_LR); % decoding choice
        end
        Activity_highV = highTIV_all.activity(:,:,:,idx_highV_LR);
        
        for frame = 1 : size(Activity_highV,3)
            thisFrame = reshape(squeeze(Activity_highV(:,:,frame,:)), [], sample_num*4);
            
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
    Accuracy_data_lowV = nan(size(lowTIV_all.activity,3), 10); % all frames, 10 times repeated cross validation
    Accuracy_shuffled_lowV = nan(size(lowTIV_all.activity,3), 10);
    
    for t = 1 : size(Accuracy_data_lowV, 2)
        
        msize = numel(sample_lowV_LStim_C); iidx_C = randperm(msize);
        iidx_C = sample_lowV_LStim_C(iidx_C(1:sample_num));
        
        msize = numel(sample_lowV_LStim_E); iidx_E = randperm(msize);
        iidx_E = sample_lowV_LStim_E(iidx_E(1:sample_num));
        
        idx_lowV_LStim = [iidx_C, iidx_E];
        
        
        msize = numel(sample_lowV_RStim_C); iidx_C = randperm(msize);
        iidx_C = sample_lowV_RStim_C(iidx_C(1:sample_num));
        
        msize = numel(sample_lowV_RStim_E); iidx_E = randperm(msize);
        iidx_E = sample_lowV_RStim_E(iidx_E(1:sample_num));
        
        idx_lowV_RStim = [iidx_C, iidx_E];
        
        
        
        
        
        idx_lowV_LR = [idx_lowV_LStim, idx_lowV_RStim];
        if plot_index(1) == 1
            keys = lowTIV_all.raw_data.CorrectSide(idx_lowV_LR);    % decoding stimulus
        elseif plot_index(2) == 1
            keys = lowTIV_all.raw_data.ResponseSide(idx_lowV_LR);   % decoding choice
        end
        Activity_lowV = lowTIV_all.activity(:,:,:,idx_lowV_LR);
        
        for frame = 1 : size(Activity_lowV,3)
            thisFrame = reshape(squeeze(Activity_lowV(:,:,frame,:)), [], sample_num*4);
            
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
    xlabel('Frames');
    ylabel('Accuracy(%)');
    if plot_index(1) == 1
        TITLE = ['Linear Classifier for predicting the stimulus based on ', region, ', ', mousename];
    elseif plot_index(2) == 1
        TITLE = ['Linear Classifier for predicting the choice based on ', region, ', ', mousename];
    end
    title(TITLE);
    set(gca,'box','off');
    set(gca,'tickdir','out');
    hold off
    
    clear curve1 curve2 curve3 curve4 TITLE
    
    
elseif sum(plot_index) > 1
    
    disp('Function ''EncodEfficiency_balancedRW'' only be able to decode one variable at one time!');
    
end


end