%% This code is written for analysing the mice behavior videos got from Simon & Richard's project
%% Before running this code, the videos need to be processed by DeepLabCut and got the .cvs output files of all trial videos
%% Please notice, optogenetic trials and widefield imaging trials locate in different sessions
fPath = 'C:\Data\churchland\CY_DLCproject\Fez7_SpatialDisc_Jan32_2020_Session1\Fez7_SpatialDisc_Jan32_2020_rawVideos\'
mousename = 'Fez7'
Mice_Behavior_Analysis_Function(fPath, mousename)

function [] = Mice_Behavior_Analysis_Function(fPath, mousename)

%% 1st, loading DeepLabCut output files and aligned camera frame times.
% the later one can be got by running 'Behavior_alignVideoFrames.m' from Simon
[Lateral_allFrames, Bottom_allFrames] = getLabelEachFrame(fPath, mousename);

% back to upper folder
downpath = regexp(fPath,'\','split');
uppath = [];
for a = 1 : (size(downpath,2) - 2)
    uppath = [uppath cell2mat(downpath(a)) '\'];
end

aligned_FrameTime = dir([uppath mousename '_SpatialDisc_*' 'cameraTimes.mat']);
aligned_FrameTime = load([uppath aligned_FrameTime.name]);  % 1st row for lateral camera, 2nd row for bottom one 
clear downpath a

global mouse_name   % this name is widely used in following functions
mouse_name = mousename;


%% 2nd, extacting movement information from the output of DLC
raw_data = dir([uppath mousename '_SpatialDisc_*' 'frameTimes']);
raw_data_file = dir([uppath raw_data.name '\' mousename '_SpatialDisc_*' 'Session1.mat']);
if isempty(raw_data_file)
    raw_data_file = dir([uppath raw_data.name '\' mousename '_SpatialDisc_*' 'Session2.mat']);
    if isempty(raw_data_file)
        raw_data_file = dir([uppath raw_data.name '\' mousename '_SpatialDisc_*' 'Session3.mat']);
    end
end
raw_data = load([raw_data_file.folder '\' raw_data_file.name]);
raw_data = raw_data.SessionData;

if contains(fPath,'Jan32','IgnoreCase',true)
    aligned_FrameTime = aligned_FrameTime.aligned_FrameTime; 
elseif contains(fPath,'Jan33','IgnoreCase',true) 
    aligned_FrameTime = aligned_FrameTime.aligned_FrameTime;
end

[V1_activity, M2_activity, raw_data, Lateral_allFrames, Bottom_allFrames, aligned_FrameTime] = OpenImaging...
    (uppath, raw_data, Lateral_allFrames, Bottom_allFrames, aligned_FrameTime); % opening widefiled imaging files and align the trials to raw_data
clear uppath

[Lateral_allFrames, Bottom_allFrames, aligned_FrameTime, raw_data, V1_activity, M2_activity] = FrameProcessing...
    (fPath, Lateral_allFrames, Bottom_allFrames, aligned_FrameTime, raw_data, V1_activity, M2_activity); % pre-processing the frames


%% 3rd, dimensionality reduction
divide_mode = 'responseside';   % what're available: 'stimulus', 'opto', 'optotype', 'outcome', 'responseside', 'formeroutcome', 'formerresponseside', 'random'
plot_index = [0,0,0,0]; %Max can change first index from 1 to zero
[overall_PCAmatrix] = Mice_DimensionReduction(Lateral_allFrames, Bottom_allFrames, aligned_FrameTime, raw_data, divide_mode, plot_index);

[Signi_idx] = HistogramAnalysis(fPath, overall_PCAmatrix, divide_mode, raw_data);    % look at how each label changes with trial going

variableList = {'opto', 'outcome', 'responseside', 'formeroutcome', 'formerresponseside'};  % The group labels used to test correlations
Correlations(overall_PCAmatrix, raw_data, variableList);

%dPCA_Mouse(overall_PCAmatrix, raw_data); not needed right now


%% 4th, Linear regression
[Group_LowVariance, Group_HighVariance] = LinearRegression(overall_PCAmatrix, raw_data);
plot_index = [0, 1];    % what're available: decoding stimulus, decoding choice
region = 'M2';  % Here the region denotes LocaNMF regions, please check the map
                % what're available: M1, M2, Visual, Auditory, Somatosensory, PPC, RSC, Olfactory
EncodEfficiency(raw_data, V1_activity, M2_activity, Group_LowVariance, Group_HighVariance, plot_index);
EncodEfficiency_balancedRW(fPath, plot_index, region);


%% 5th, cluster analysis
ClusterAnalysis_index = [0];    % what're available: t-sne
Clusteranalysis(overall_PCAmatrix, ClusterAnalysis_index, divide_mode, raw_data);


end