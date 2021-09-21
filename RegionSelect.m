% This function is used for selecting the neural activity in specific LocaNMF regions

function [region_activity] = RegionSelect(regionMap, A, nC, region)

selected_region = zeros(size(regionMap));
if isequal(region, 'M1')
    selected_region(regionMap == 253) = 1;   % 253, 3, etc. are the codes of brain regions in regionMap (LocaNMF map)
    selected_region(regionMap == 3) = 1;
    
elseif isequal(region, 'M2')
    selected_region(regionMap == 254) = 1;  
    selected_region(regionMap == 2) = 1;
    
elseif isequal(region, 'Visual')
    selected_region(regionMap == 247) = 1;
    selected_region(regionMap == 9) = 1;
    
elseif isequal(region, 'Auditory')
    selected_region(regionMap == 251) = 1;
    selected_region(regionMap == 5) = 1;
    
elseif isequal(region, 'Somatosensory')
    selected_region(regionMap == 252) = 1;
    selected_region(regionMap == 4) = 1;
    
elseif isequal(region, 'PPC')
    selected_region(regionMap == 249) = 1;
    selected_region(regionMap == 7) = 1;
    
elseif isequal(region, 'RSC')
    selected_region(regionMap == 248) = 1;
    selected_region(regionMap == 8) = 1;
    
elseif isequal(region, 'Olfactory')
    selected_region(regionMap == 255) = 1;
    selected_region(regionMap == 1) = 1;
    
else
    region_activity = [];
    return
end



A_region = A;
for i = 1 : size(A,3)
    A_region(:,:,i) = A_region(:,:,i) .* selected_region;
end

[A_region, x_length, y_length, ~] = regionCut(A_region, selected_region, 1, []); % To reduce the size of the final matrix, we only use the non-zero part of A_region


A_region = reshape(A_region, [], size(A,3));
nC_region = reshape(nC, size(nC, 1), []);
region_activity = A_region * nC_region;
region_activity = reshape(region_activity, y_length, x_length, size(nC, 2), size(nC, 3));
region_activity(isnan(region_activity)) = 0;
clear y_length x_length i

[~, ~, ~, region_activity] = regionCut([], [], 2, region_activity); % To reduce the size of region_activity, we only use the non-zero part
 
end





%% Auxillary functions
%%
% To reduce the size of the final matrix, we only use the non-zero part of A_region
function [A_region, x_length, y_length, region_activity] = regionCut(A_region, selected_region, idx, region_activity)

if idx == 1 % The first time using this function, deleting the zeros on lateral sides
    
    x_border = sum(selected_region,1);
    x_border = [find(x_border~=0,1), find(x_border~=0,1,'last')];
    y_border = sum(selected_region,2);
    y_border = [find(y_border~=0,1), find(y_border~=0,1,'last')];
    
    A_region = A_region(y_border(1):y_border(2), x_border(1):x_border(2), :, :);
    x_length = diff(x_border) + 1;
    y_length = diff(y_border) + 1;
    
    region_activity = [];
    
elseif idx == 2 % The first time using this function, deleting the zeros in the middle
    
    sampleFrame = region_activity(:,:,55,30) .* 100;
    middleLine = floor(size(sampleFrame, 2)/2);
    
    if sum(sampleFrame(:, middleLine)) == 0
        LHalf = sampleFrame(:, 1:middleLine);
        RHalf = sampleFrame(:, middleLine+1 : end);
        
        LBorder = sum(LHalf,1);
        LBorder = find(LBorder~=0,1,'last');
        RBorder = sum(RHalf,1);
        RBorder = find(RBorder~=0,1);
        RBorder = middleLine + RBorder;
        
        region_activity(:, LBorder:RBorder, :, :) = [];
    end
    
    A_region = [];
    x_length = [];
    y_length = [];
end

end