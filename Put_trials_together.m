% This function is used to put seperated trials together

function Put_trials_together(mousename, date)

fPath = ['F:\Mice_Project\', mousename, '_SpatialDisc_'];

%% Creating a Jan 32th folder for saving data collection
if ~exist([fPath, 'Jan34_2020_Session1'], 'dir')
    mkdir([fPath, 'Jan34_2020_Session1']);
    
    i = [fPath, 'Jan34_2020_Session1', '\'];
    mkdir([i, mousename, '_SpatialDisc_Jan34_2020_frameTimes']);
    mkdir([i, mousename, '_SpatialDisc_Jan34_2020_rawVideos']);
    
    mkdir([i, mousename, '_SpatialDisc_Jan34_2020_rawVideos\Bottom']);
    mkdir([i, mousename, '_SpatialDisc_Jan34_2020_rawVideos\Lateral']);
end


%% Put files in Jan 32th
for a = 1 : length(date)
    thisPath = [fPath, date{a}, '\'];
    
    c = dir([thisPath, mousename '*_rawVideos']);
    lateral_path = [thisPath, c.name, '\Lateral\'];
    bottom_path = [thisPath, c.name, '\Bottom\'];
    
    
    target_bottomFolder = [fPath, 'Jan34_2020_Session1\', mousename, '_SpatialDisc_Jan34_2020_rawVideos\Bottom'];
    target_lateralFolder = [fPath, 'Jan34_2020_Session1\', mousename, '_SpatialDisc_Jan34_2020_rawVideos\Lateral'];
    
    bottomFiles = dir([bottom_path, mousename '*.csv']);
    lateralFiles = dir([lateral_path, mousename '*.csv']);
    
    if length(bottomFiles) == length(lateralFiles)
        for b = 1 : length(bottomFiles)
            bottomname = [bottomFiles(b).folder, '\', bottomFiles(b).name];
            lateralname = [lateralFiles(b).folder, '\', lateralFiles(b).name];
            
            copyfile(bottomname,target_bottomFolder);
            copyfile(lateralname,target_lateralFolder);
        end     
    else
        fprintf(2, 'Lateral and bottom cameras have different video numbers!! \n');
    end
    
    
    
    c = dir([thisPath, mousename '*_frameTimes']);
    frametimeFolder = [thisPath, c.name, '\'];
    
    d = dir([frametimeFolder, '*', date{a}, '.mat']);
    if a == 1
        all_rawdata = load([frametimeFolder, d.name]);
        all_rawdata = all_rawdata.SessionData;
        all_rawdata.Notes(end) = [];    % rawdata.Notes has one redundant element in the first postion
    else
        this_rawdata = load([frametimeFolder, d.name]);
        this_rawdata = this_rawdata.SessionData;
        this_rawdata.Notes(end) = [];
        
        fn = fieldnames(this_rawdata);
        for k=1:numel(fn)    
            all_rawdata.(fn{k}) = [all_rawdata.(fn{k}), this_rawdata.(fn{k})];
        end
    end
    
    e = dir([frametimeFolder, '*', 'cameraTimes.mat']);
    if a == 1
        all_cameraTimes = load([frametimeFolder, e.name]);    
    else
        this_cameraTimes = load([frametimeFolder, e.name]);
        
        fn = fieldnames(this_cameraTimes);
        for k=1:numel(fn)
            all_cameraTimes.(fn{k}) = [all_cameraTimes.(fn{k}), this_cameraTimes.(fn{k})];
        end
    end
     
    
end

all_rawdata.SessionNames = date;    % Save where the sessions come from
clear a b c d e i k fn frametimeFolder lateral_path bottom_path

target_frameTimesFolder = [fPath, 'Jan34_2020_Session1', '\', mousename, '_SpatialDisc_Jan34_2020_frameTimes\'];
frameTimes_name = [mousename, '_SpatialDisc_Jan34_2020_Session1_cameraTimes.mat'];
aligned_FrameTime = all_cameraTimes;
save([target_frameTimesFolder frameTimes_name],'aligned_FrameTime');

rawdata_name = [mousename, '_SpatialDisc_Jan34_2020_Session1.mat'];
SessionData = all_rawdata;
save([target_frameTimesFolder rawdata_name],'SessionData');



end