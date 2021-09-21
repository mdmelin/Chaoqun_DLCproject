%% Opening the widefield imaging files, and getting the neural activity from decomposed matrices

function [V1_activity, M2_activity, raw_data, Lateral_allFrames, Bottom_allFrames, aligned_FrameTime] = OpenImaging...
    (fPath, raw_data, Lateral_allFrames, Bottom_allFrames, aligned_FrameTime)

global mouse_name  
mousename = mouse_name;

fPath = dir([fPath mousename '_SpatialDisc_*' 'Imaging']);
fPath = [fPath.folder, '\', fPath.name, '\'];
if ~exist(fPath, 'dir') 
    disp('This session does not have imaging data. Imaging data loading is skipped.');
    V1_activity = [];
    M2_activity = [];
    return
end


load([fPath, 'QR.mat'], 'nanIdx'); %index that was used to create AC
load([fPath, 'rsVc.mat'], 'Vc'); %downsampled version of Vc (15Hz instead of 30Hz). Stimulus at frame 45.
load([fPath, 'newAC_20_50.mat']);
load([fPath, 'rsVc.mat'], 'bTrials');   % for aligning behavioral rawdata raw_data and imaging data rsVc.

[raw_data, Lateral_allFrames, Bottom_allFrames, aligned_FrameTime] = selectBehaviorTrials_CY(raw_data, bTrials, Lateral_allFrames, Bottom_allFrames, aligned_FrameTime);
nC = NaN(size(C,1), size(Vc,2),size(Vc,3), 'single'); %pre-allocate then fill with data
nC(:, ~nanIdx) = C; %this has the same size as Vc (downsampled to 15Hz)



%% V1
V1_map = zeros(size(regionMap));
V1_map(regionMap == 251) = 1;   % In "regionMap" matrix, left "A1" is labeled as 251
V1_map(regionMap == 5) = 1;     % In "regionMap" matrix, right "A1" is labeled as 5
 
A_V1 = A;   
for i = 1 : size(A,3)
   A_V1(:,:,i) = A_V1(:,:,i) .* V1_map;
end

A_V1 = A_V1(181:540, 21:570, :, :);    % To reduce the size of the final matrix, we only use the non-zero part of A_V1

A_V1 = reshape(A_V1, [], size(A,3));
nC_V1 = reshape(nC, size(nC, 1), []);
V1_activity = A_V1 * nC_V1;
V1_activity = reshape(V1_activity, 360, 550, size(nC, 2), size(nC, 3));
V1_activity(isnan(V1_activity)) = 0;
V1_activity(:, 131:410, :, :) = [];

clear A_V1 nC_V1


%% M2
M2_map = zeros(size(regionMap));
M2_map(regionMap == 254) = 1;   % In "regionMap" matrix, left M2 is labeled as 254
M2_map(regionMap == 2) = 1;     % In "regionMap" matrix, right M2 is labeled as 2

A_M2 = A;
for i = 1 : size(A,3)
   A_M2(:,:,i) = A_M2(:,:,i) .* M2_map;
end

A_M2 = A_M2(91:320, 131:450, :);    % To reduce the size of the final matrix, we only use the non-zero part of A_M2

A_M2 = reshape(A_M2, [], size(A,3));
nC_M2 = reshape(nC, size(nC, 1), []);
M2_activity = A_M2 * nC_M2;
M2_activity = reshape(M2_activity, 230, 320, size(nC, 2), size(nC, 3));
M2_activity(isnan(M2_activity)) = 0;

end