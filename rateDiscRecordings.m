%% This script comes from Simon, 12/14/2020

function [dataOverview, motorLabels, sensorLabels, cogLabels, segIdx, segLabels, segIdxRealign, fPath, trainDates, allRegs] = rateDiscRecordings
%overview over recordings that are used in the rate discrimination study.
%Also includes some other basic variables to ensure that different codes
%will use the same values.

dataOverview = {
    
'mSM63' 'audioDetect' 'ALM-MM' '07-Jun-2018'; ...
'mSM64' 'audioDetect' 'MM-ALM' '07-Jun-2018'; ...
'mSM65' 'audioDetect' 'MM-ALM' '14-Jun-2018'; ...
'mSM66' 'audioDetect' 'ALM-MM' '14-Jun-2018'; ...

'Fez7' 'audioDetect' 'ALM-MM' '14-Jun-2018'; ...
'Fez10' 'audioDetect' 'ALM-MM' '02-Jan-2019'; ...

'Plex01' 'audioDetect' 'ALM-MM' '02-Jan-2019'; ...
'Plex02' 'audioDetect' 'ALM-MM' '14-Jun-2018'; ...

'Plex60' 'audioDetect' 'ALM-MM' '09-Jun-2020'; ...
'Plex61' 'audioDetect' 'ALM-MM' '09-Jun-2020'; ...

'Plex65' 'audioDetect' 'ALM-MM' '09-Jun-2020'; ...
'Plex66' 'audioDetect' 'ALM-MM' '09-Jun-2020'; ...

'CSP22' 'audioDetect' 'ALM-MM' '29-Jan-2020'; ...
'CSP23' 'audioDetect' 'ALM-MM' '29-Jan-2020'; ...
'CSP32' 'audioDetect' 'ALM-MM' '29-Jan-2020'; ...

};

%regressors for motor-based reconstruction
motorLabels = {'lGrab' 'rGrab' 'lLick' 'rLick' 'lick' 'piezo' 'whisk' 'nose'... 
    'pupil' 'body' 'eye' 'jaw' 'groom' 'ear' 'Move' 'bhvVideo'}; 

%regressors for sensory-based reconstruction
sensorLabels = {'lfirstTacStim' 'lTacStim' 'rfirstTacStim' 'rTacStim' ...
    'lfirstAudStim' 'lAudStim' 'rfirstAudStim' 'rAudStim' 'handleSound'}; 

%regressors for cognitive reconstruction
cogLabels = {'reward' 'prevReward' 'prevChoice' 'water' 'lhandleChoice' ...
    'rhandleChoice' 'lstimChoice' 'rstimChoice' 'lresponseChoice' 'rresponseChoice'}; 

%segment indices to compute changes per task episodes.
% segIdx = [2 0.75 1.5 1 1]; %maximal duration of each segment in seconds
segIdx = [2 0.75 1.25 0.75 1]; %maximal duration of each segment in seconds (made stim and delay 0.25s shorter to avoid single trials dominating the average).

segLabels = {'Baseline' 'Handle' 'Stim' 'Wait' 'Response'};
% segIdxRealign = {1:60 61:82 83:127 128:157 158:187}; %segment index after realignment on individual segments
segIdxRealign = NaN; %dont use this right now

% file path on grid server
% fPath = 'U:\smusall\BpodImager\Animals\';
fPath = 'Y:\data\BpodImager\Animals\';

% regressors for variance analysis
allRegs = {'full' ...
        'Choice' 'handleChoice' 'stimChoice' 'respChoice' ... %choice regressors
        'reward' 'prevReward' 'prevChoice' 'water'  ... %task regressors
        'audioStim' 'lfirstAudStim' 'rfirstAudStim' 'lAudStim' 'rAudStim' 'handleSound' ...  %stim regressors
        'licks' 'handles' 'piezo' 'whisk' 'nose' 'pupil' 'body' 'eye' 'jaw' 'groom' 'ear' 'video'}; %movement regressors


Cnt = 0; %counter for animals
    
% Dates for mSM63 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('mSM63','Y:\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'mSM63; Audio detection'; ...
    '5th prctile: 15-Jun-2018'; ...
    '50th prctile: 26-Jun-2018'; ...
    '95th prctile: 03-Jul-2018'; ...
    'Last detection: 06-Jul-2018'; ...
    'mSM63; Audio discrimination'; ...
    'First audio discrimination: 09-Jul-2018'; ...
    'Last audio discrimination: 20-Jul-2018'; ...
    'First novice tactile discrimination: 23-Jul-2018'; ...
    'Last novice tactile discrimination: 03-Aug-2018'; ...
    'mSM63; Tactile detection'; ...
    '5th prctile: 07-Aug-2018'; ...
    '50th prctile: 15-Aug-2018'; ...
    '95th prctile: 23-Aug-2018'; ...
    'mSM63; Tactile discrimination'; ...
    'First tactile discrimination: 14-Sep-2018'; ...
    'Last tactile discrimination: 19-Oct-2018';       
    };

% Dates for mSM64 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('mSM64','Y:\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'mSM64; Audio detection'; ...
    '5th prctile: 13-Jun-2018'; ...
    '50th prctile: 18-Jun-2018'; ...
    '95th prctile: 20-Jun-2018'; ...
    'Last detection: 29-Jun-2018'; ...
    'mSM64; Audio discrimination'; ...
    'First audio discrimination: 02-Jul-2018'; ...
    'Last audio discrimination: 27-Jul-2018'; ...
    'First novice tactile discrimination: 30-Jul-2018'; ...
    'Last novice tactile discrimination: 14-Aug-2018'; ...
    'mSM64; Tactile detection'; ...
    '5th prctile: 16-Aug-2018'; ...
    '50th prctile: 21-Aug-2018'; ...
    '95th prctile: 23-Aug-2018'; ...
    'mSM64; Tactile discrimination'; ...
    'First tactile discrimination: 14-Sep-2018'; ...
    'Last tactile discrimination: 02-Oct-2018'; ...
    };

% Dates for mSM65 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('mSM65','Y:\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'mSM65; Audio detection'; ...
    '5th prctile: 11-Jun-2018'; ...
    '50th prctile: 14-Jun-2018'; ...
    '95th prctile: 19-Jun-2018'; ...
    'Last detection: 26-Jun-2018'; ...
    'mSM65; Audio discrimination'; ...
    'First audio discrimination: 27-Jun-2018'; ...
    'Last audio discrimination: 16-Jul-2018'; ...
    'First novice tactile discrimination: 17-Jul-2018'; ...
    'Last novice tactile discrimination: 23-Jul-2018'; ...
    'mSM65; Tactile detection'; ...
    '5th prctile: 24-Jul-2018'; ...
    '50th prctile: 01-Aug-2018'; ...
    '95th prctile: 08-Aug-2018'; ...
    'mSM65; Tactile discrimination'; ...
    'First tactile discrimination: 08-Aug-2018'; ...
    'Last tactile discrimination: 07-Sep-2018'; ...
    };

% Dates for mSM66 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('mSM66','Y:\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'mSM66; Audio detection'; ...
    '5th prctile: 12-Jun-2018'; ...
    '50th prctile: 13-Jun-2018'; ...
    '95th prctile: 18-Jun-2018'; ...
    'Last detection: 26-Jun-2018'; ...
    'mSM66; Audio discrimination'; ...
    'First audio discrimination: 27-Jun-2018'; ...
    'Last audio discrimination: 16-Jul-2018'; ...
    'First novice tactile discrimination: 17-Jul-2018'; ...
    'Last novice tactile discrimination: 23-Jul-2018'; ...
    'mSM66; Tactile detection'; ...
    '5th prctile: 24-Jul-2018'; ...
    '50th prctile: 27-Jul-2018'; ...
    '95th prctile: 01-Aug-2018'; ...
    'mSM66; Tactile discrimination'; ...
    'First tactile discrimination: 08-Aug-2018'; ...
    'Last tactile discrimination: 07-Sep-2018'; ...
    };

% Dates for Fez7 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('Fez7','\\grid-hs\churchland_nlsas_data\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'Fez7; Audio detection'; ...
    '5th prctile: 26-Nov-2018'; ...
    '50th prctile: 30-Nov-2018'; ...
    '95th prctile: 05-Dec-2018'; ...
    'Last detection: 11-Dec-2018'; ...
    'Fez7; Audio discrimination'; ...
    'First audio discrimination: 12-Dec-2018'; ...
    'Last audio discrimination: 08-Jan-2019'; ...
    'First novice tactile discrimination: 09-Jan-2019'; ...
    'Last novice tactile discrimination: 18-Jan-2019'; ...
    'Fez7; Tactile detection'; ...
    '5th prctile: 24-Jan-2019'; ...
    '50th prctile: 04-Feb-2019'; ...
    '95th prctile: 12-Feb-2019'; ...
    'Fez7; Tactile discrimination'; ...
    'First tactile discrimination: 19-Feb-2019'; ...
    'Last tactile discrimination: 29-Mar-2019'; ...
    };


% Dates for Fez10 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('Fez10','Y:\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'Fez10; Audio detection'; ...
    '5th prctile: 26-Nov-2018'; ...
    '50th prctile: 30-Nov-2018'; ...
    '95th prctile: 07-Dec-2018'; ...
    'Last detection: 11-Dec-2018'; ...
    'Fez10; Audio discrimination'; ...
    'First audio discrimination: 12-Dec-2018'; ...
    'Last audio discrimination: 08-Jan-2019'; ...
    'First novice tactile discrimination: 09-Jan-2019'; ...
    'Last novice tactile discrimination: 18-Jan-2019'; ...
    'Fez10; Tactile detection'; ...
    '5th prctile: 24-Jan-2019'; ...
    '50th prctile: 06-Feb-2019'; ...
    '95th prctile: 15-Feb-2019'; ...
    'Fez10; Tactile discrimination'; ...
    'First tactile discrimination: 19-Feb-2019'; ...
    'Last tactile discrimination: 29-Mar-2019'; ...
    };

% Dates for Plex01 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('Plex01','Y:\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'Plex01; Audio detection'; ...
    '5th prctile: 27-Nov-2018'; ...
    '50th prctile: 03-Dec-2018'; ...
    '95th prctile: 11-Dec-2018'; ...
    'Last detection: 14-Dec-2018'; ...
    'Plex01; Audio discrimination'; ...
    'First audio discrimination: 17-Dec-2018'; ...
    'Last audio discrimination: 07-Jan-2019'; ...
    'First novice tactile discrimination: 09-Jan-2019'; ...
    'Last novice tactile discrimination: 18-Jan-2019'; ...
    'Plex01; Tactile detection'; ...
    '5th prctile: 31-Jan-2019'; ...
    '50th prctile: 08-Feb-2019'; ...
    '95th prctile: 19-Feb-2019'; ...
    'Plex01; Tactile discrimination'; ...
    'First tactile discrimination: 06-Mar-2019'; ...
    'Last tactile discrimination: 15-Apr-2019'; ...
    };

% Dates for Plex02 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('Plex02','Y:\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'Plex02; Audio detection'; ...
    '5th prctile: 20-Nov-2018'; ...
    '50th prctile: 06-Dec-2018'; ...
    '95th prctile: 21-Dec-2018'; ...
    'Last detection: 08-Jan-2019'; ...
    'Plex02; Audio discrimination'; ...
    'First audio discrimination: 09-Jan-2019'; ...
    'Last audio discrimination: 08-Feb-2019'; ...
    'First novice tactile discrimination: 11-Feb-2019'; ...
    'Last novice tactile discrimination: 15-Feb-2019'; ...
    'Plex02; Tactile detection'; ...
    '5th prctile: 26-Feb-2019'; ...
    '50th prctile: 06-Mar-2019'; ...
    '95th prctile: 15-Mar-2019'; ...
    'Plex02; Tactile discrimination'; ...
    'First tactile discrimination: 25-Mar-2019'; ...
    'Last tactile discrimination: 26-Apr-2019'; ...
    };

% Dates for Plex60 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('Plex60','\\grid-hs\churchland_nlsas_data\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'Plex60; Audio detection'; ...
    '5th prctile: 17-Jun-2020'; ...
    '50th prctile: 19-Jun-2020'; ...
    '95th prctile: 22-Jun-2020'; ...
    'Last detection: 07-Jul-2020'; ...
    'Plex60; Audio discrimination'; ...
    'First audio discrimination: 07-Jul-2020'; ...
    'Last audio discrimination: 31-Jul-2020'; ...
    };
trainDates{Cnt}{17} = [];


% Dates for Plex61 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('Plex61','\\grid-hs\churchland_nlsas_data\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'Plex61; Audio detection'; ...
    '5th prctile: 16-Jun-2020'; ...
    '50th prctile: 17-Jun-2020'; ...
    '95th prctile: 19-Jun-2020'; ...
    'Last detection: 11-Jul-2020'; ...
    'Plex61; Audio discrimination'; ...
    'First audio discrimination: 12-Jul-2020'; ...
    'Last audio discrimination: 31-Jul-2020'; ...
    };
trainDates{Cnt}{17} = [];

% Dates for Plex65 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('Plex65','\\grid-hs\churchland_nlsas_data\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'Plex65; Audio detection'; ...
    '5th prctile: 12-Aug-2020'; ...
    '50th prctile: 13-Aug-2020'; ...
    '95th prctile: 14-Aug-2020'; ...
    'Last detection: 19-Aug-2020'; ...
    'Plex65; Audio discrimination'; ...
    'First audio discrimination: 19-Aug-2020'; ...
    'Last audio discrimination: 08-Sep-2020'; ...
    };
trainDates{Cnt}{17} = [];

% Dates for Plex66 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('Plex66','\\grid-hs\churchland_nlsas_data\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'Plex66; Audio detection'; ...
    '5th prctile: 12-Aug-2020'; ...
    '50th prctile: 13-Aug-2020'; ...
    '95th prctile: 14-Aug-2020'; ...
    'Last detection: 19-Aug-2020'; ...
    'Plex66; Audio discrimination'; ...
    'First audio discrimination: 19-Aug-2020'; ...
    'Last audio discrimination: 25-Sep-2020'; ...
    };
trainDates{Cnt}{17} = [];


% Dates for CSP22 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('CSP22','\\grid-hs\churchland_nlsas_data\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'CSP22; Audio detection'; ...
    '5th prctile: 29-Jan-2020'; ...
    '50th prctile: 30-Jan-2020'; ...
    '95th prctile: 02-Feb-2020'; ...
    'Last detection: 11-Feb-2020'; ...
    'CSP22; Audio discrimination'; ...
    'First audio discrimination: 11-Feb-2020'; ...
    'Last audio discrimination: 02-Mar-2020'; ...
    };
trainDates{Cnt}{17} = [];

% Dates for CSP23 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('CSP22','\\grid-hs\churchland_nlsas_data\data\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'CSP23; Audio detection'; ...
    '5th prctile: 29-Jan-2020'; ...
    '50th prctile: 03-Feb-2020'; ...
    '95th prctile: 05-Feb-2020'; ...
    'Last detection: 11-Feb-2020'; ...
    'CSP23; Audio discrimination'; ...
    'First audio discrimination: 11-Feb-2020'; ...
    'Last audio discrimination: 02-Mar-2020'; ...
    };
trainDates{Cnt}{17} = [];

% Dates for CSP32 - Generated by running: [~,~,allDates] = RateDisc_learningCurves('CSP32','G:\Google Drive\Behavior_Simon\');
Cnt = Cnt + 1;
trainDates{Cnt} = {
    'CSP32; Audio detection'; ...
    '5th prctile: 30-Jun-2020'; ...
    '50th prctile: 02-Jul-2020'; ...
    '95th prctile: 06-Jul-2020'; ...
    'Last detection: 11-Jul-2020'; ...
    'CSP23; Audio discrimination'; ...
    'First audio discrimination: 12-Jul-2020'; ...
    'Last audio discrimination: 24-Jul-2020'; ...
    };
trainDates{Cnt}{17} = [];

