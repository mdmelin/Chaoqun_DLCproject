% This function is used for selecting the neural activity and behavioral data in specific trials, 
% according to "bTrials" and "original_OrderIdx"

function [highTIV, lowTIV] = TrialSelect(region_activity, raw_data, bTrials, original_OrderIdx, session_idx)
% Processing highTIV trials first
a = original_OrderIdx.Trials_HighTIV(2,:);
a = find(a == session_idx);
b = original_OrderIdx.Trials_HighTIV(1,:);
highTIV_trials = b(a);
for i = 1 : length(a)
    highTIV_trials(i) = find(bTrials == highTIV_trials(i));    
end
clear i a b

highTIV_activity = region_activity(:, :, :, highTIV_trials);

highTIV_raw_data.nTrials = length(highTIV_trials);
highTIV_raw_data.Rewarded = raw_data.Rewarded(highTIV_trials);
highTIV_raw_data.ResponseSide = raw_data.ResponseSide(highTIV_trials);
highTIV_raw_data.CorrectSide = raw_data.CorrectSide(highTIV_trials);


% Then lowTIV trials
a = original_OrderIdx.Trials_LowTIV(2,:);
a = find(a == session_idx);
b = original_OrderIdx.Trials_LowTIV(1,:);
lowTIV_trials = b(a);
for i = 1 : length(a)
    lowTIV_trials(i) = find(bTrials == lowTIV_trials(i));    
end
clear i a b

lowTIV_activity = region_activity(:, :, :, lowTIV_trials);
clear region_activity

lowTIV_raw_data.nTrials = length(lowTIV_trials);
lowTIV_raw_data.Rewarded = raw_data.Rewarded(lowTIV_trials);
lowTIV_raw_data.ResponseSide = raw_data.ResponseSide(lowTIV_trials);
lowTIV_raw_data.CorrectSide = raw_data.CorrectSide(lowTIV_trials);

highTIV.activity = highTIV_activity;
highTIV.raw_data = highTIV_raw_data;
lowTIV.activity = lowTIV_activity;
lowTIV.raw_data = lowTIV_raw_data;

clear highTIV_activity highTIV_raw_data lowTIV_activity lowTIV_raw_data



% Notice that only a small part of trials are error trials, especially in the lowTIV group.
% To further reduce the size of neural activity matrix, we only get all the error trials
% and randomly select 2 times number of correct trials.
error_highTIV = find(highTIV.raw_data.Rewarded == 0);   % All no-response trials were already deleted in "LinearRegression" function 
correct_highTIV = find(highTIV.raw_data.Rewarded == 1);

msize = numel(correct_highTIV);
idx = randperm(msize);
correct_highTIV = correct_highTIV(idx(1:length(error_highTIV)*1.5));
wanted_highTIV = [correct_highTIV, error_highTIV];

highTIV.activity = highTIV.activity(:,:,:,wanted_highTIV);
highTIV.raw_data.nTrials = length(wanted_highTIV);
highTIV.raw_data.Rewarded = highTIV.raw_data.Rewarded(wanted_highTIV);
highTIV.raw_data.ResponseSide = highTIV.raw_data.ResponseSide(wanted_highTIV);
highTIV.raw_data.CorrectSide = highTIV.raw_data.CorrectSide(wanted_highTIV);

clear error_highTIV correct_highTIV msize idx wanted_highTIV


error_lowTIV = find(lowTIV.raw_data.Rewarded == 0);   
correct_lowTIV = find(lowTIV.raw_data.Rewarded == 1);

msize = numel(correct_lowTIV);
idx = randperm(msize);
correct_lowTIV = correct_lowTIV(idx(1:length(error_lowTIV)*2));
wanted_lowTIV = [correct_lowTIV, error_lowTIV];

lowTIV.activity = lowTIV.activity(:,:,:,wanted_lowTIV);
lowTIV.raw_data.nTrials = length(wanted_lowTIV);
lowTIV.raw_data.Rewarded = lowTIV.raw_data.Rewarded(wanted_lowTIV);
lowTIV.raw_data.ResponseSide = lowTIV.raw_data.ResponseSide(wanted_lowTIV);
lowTIV.raw_data.CorrectSide = lowTIV.raw_data.CorrectSide(wanted_lowTIV);

clear error_lowTIV correct_lowTIV msize idx wanted_lowTIV


end