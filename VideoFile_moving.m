% This code is used to put lateral and bottom vidoes into different folders

function [] = VideoFile_moving(fPath, mousename)

lateral_videos = dir([fPath mousename '_SpatialDisc*_1.mp4']);
num_lateral_videos = size(lateral_videos,1);

bottom_videos = dir([fPath mousename '_SpatialDisc*_2.mp4']);
num_bottom_videos = size(bottom_videos,1);

if ~exist([fPath 'Lateral'], 'dir')
    mkdir([fPath 'Lateral']);
end
if ~exist([fPath 'Bottom'], 'dir')
    mkdir([fPath 'Bottom']);
end

if num_lateral_videos == num_bottom_videos
    for x = 1 : num_lateral_videos
        % move lateral camera videos
        orignial = [fPath lateral_videos(x).name];
        destination = [fPath 'Lateral\'];
        movefile(orignial, destination);
        
        % move bottom camera videos
        orignial = [fPath bottom_videos(x).name];
        destination = [fPath 'Bottom\'];
        movefile(orignial, destination);       
    end
else
    fprintf(2, 'Lateral and bottom cameras have different video numbers!! \n');
end


end