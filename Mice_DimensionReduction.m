%% Doing dimensionality reduction on mice video files

function [overall_PCAmatrix_backup] = Mice_DimensionReduction(Lateral_allFrames, Bottom_allFrames, aligned_FrameTime, raw_data, divide_mode, plot_index)

%% 1st, aligning all frames to the stimulus-on time point
% There is a 30 frames delay between StimulusOn and HandlesIn
events_time_lateral = zeros(length(Lateral_allFrames.frames), 5);
events_time_bottom = zeros(length(Lateral_allFrames.frames), 5);

for a = 1 : length(Lateral_allFrames.frames)
    events_time_lateral(a, 1) = aligned_FrameTime.handlesIn(1,a);    % handles coming in frame
    events_time_lateral(a, 2) = aligned_FrameTime.stimOn(1,a);       % auditory sitmulus on frame
    events_time_lateral(a, 3) = aligned_FrameTime.optoStimOn(1,a);   % optogenetics stimulation on frame
    events_time_lateral(a, 4) = aligned_FrameTime.spoutsIn(1,a);     % spouts coming in frame
    events_time_lateral(a, 5) = size(Lateral_allFrames.frames{1,a},1);   % video end frame
    
    events_time_bottom(a, 1) = aligned_FrameTime.handlesIn(2,a);
    events_time_bottom(a, 2) = aligned_FrameTime.stimOn(2,a);
    events_time_bottom(a, 3) = aligned_FrameTime.optoStimOn(2,a);
    events_time_bottom(a, 4) = aligned_FrameTime.spoutsIn(2,a);
    events_time_bottom(a, 5) = size(Bottom_allFrames.frames{1,a},1);
end



%% 2nd, making the matrix for PCA and doing overall PCA
endpoint = min([events_time_lateral(:,5)-events_time_lateral(:,2); events_time_bottom(:,5)-events_time_bottom(:,2)]);
label_num = size(Lateral_allFrames.frames{1,1},2)/3 + size(Bottom_allFrames.frames{1,1},2)/3;
overall_PCAmatrix = zeros(length(Lateral_allFrames.frames), (endpoint + 30), 2, label_num); % trialNum*timespan*(x&y coordinate)*labelNum
for a = 1 : length(Lateral_allFrames.frames)
    lateral_stimOn = aligned_FrameTime.stimOn(1,a);
    bottom_stimOn = aligned_FrameTime.stimOn(2,a);
    
    for b = -29 : endpoint
        lateral_frame_ind = lateral_stimOn + b;
        bottom_frame_ind = bottom_stimOn + b;
        
        for c = 1 : label_num
            if c <= size(Lateral_allFrames.frames{1,1},2)/3
                overall_PCAmatrix(a,(b+30),1,c) = Lateral_allFrames.frames{1,a}(lateral_frame_ind, c*3-2);
                overall_PCAmatrix(a,(b+30),2,c) = Lateral_allFrames.frames{1,a}(lateral_frame_ind, c*3-1);
            else
                overall_PCAmatrix(a,(b+30),1,c) = Bottom_allFrames.frames{1,a}(bottom_frame_ind, (c-14)*3-2);
                overall_PCAmatrix(a,(b+30),2,c) = Bottom_allFrames.frames{1,a}(bottom_frame_ind, (c-14)*3-1);
            end
        end
    end
end
clear a b c lateral_stimOn bottom_stimOn lateral_frame_ind bottom_frame_ind

overall_PCAmatrix_backup = overall_PCAmatrix;
overall_PCAmatrix = reshape(overall_PCAmatrix, [length(Lateral_allFrames.frames), (endpoint+30)*2*label_num]);
overall_PCAmatrix = GroupData_Mouse(overall_PCAmatrix, divide_mode, raw_data);
trial_markers = overall_PCAmatrix(:,end);
overall_PCAmatrix(:,end) = [];


[PCA_bases,PCA_result,latent,tsquared,explained,~] = pca(overall_PCAmatrix);

PCA_result = [PCA_result, trial_markers];
DR_visualization_Mouse(PCA_result, explained, size(overall_PCAmatrix,1), 'movement', divide_mode, plot_index);



%% 3rd, Trajectory
plotting_idx = [0];
TrajectoryPlotting(overall_PCAmatrix_backup, raw_data, divide_mode, plotting_idx);



%% 4rd, Slicing PCA
plotting_idx = [0,0];   % what're available: 3D, 2D with data grouping
SlicingPCA(overall_PCAmatrix_backup, divide_mode, raw_data, plotting_idx);



%% 5th, Using linear classifier to predict animal's response side/opto/former responseside...
% LinearClassifier(overall_PCAmatrix_backup, divide_mode, raw_data);
plotting_idx = [0,0,0];   
LinearClassifierPlus(overall_PCAmatrix_backup, raw_data, plotting_idx);

plotting_idx = [0,0];
LinearClassifierSwitch(overall_PCAmatrix_backup, raw_data, plotting_idx);



%% 6th, Using linear classifier to test the effect of 1.5s parietal/frontal stimulation
plotting_idx = [1];
LinearClassifier_LongStimu(overall_PCAmatrix_backup, raw_data, plotting_idx);


end