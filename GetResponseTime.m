%% This code is designed to get the time length of the gap between SpoutsIn and animal's 1st lick
% Please notice this task is a fixed-duration task. It doesn't have "reaction time". 

function [ResponseTime] = GetResponseTime(raw_data)

%% 1st, check the trial numbers recorded in raw_data.nTrials and raw_data.RawEvents
% They can be different sometimes
RawEvents_all = {};
for a = 1 : length(raw_data.RawEvents)
    if raw_data.nTrials(a) < length(raw_data.RawEvents(a).Trial)
        ttt = length(raw_data.RawEvents(a).Trial) - raw_data.nTrials(a);
        nnn = length(raw_data.RawEvents(a).Trial);
        raw_data.RawEvents(a).Trial((nnn-ttt+1):end) = [];
        
    elseif raw_data.nTrials(a) > length(raw_data.RawEvents(a).Trial)
        fprintf(2, ['Some RawEvents records of ',  num2str(a), 'th session are missing! \n']);
    end
    
    RawEvents_all = [RawEvents_all; raw_data.RawEvents(a).Trial(:)];
end

clear a ttt nnn


%% 2nd, get the reaction time of each trial
ResponseTime = nan(1, sum(raw_data.nTrials));

for b = 1 : length(ResponseTime)
    % The max response window is 3s. However, no-response trials will be deleted in the following steps
    ResponseTime(b) = RawEvents_all{b, 1}.States.WaitForResponse(2) - RawEvents_all{b, 1}.States.WaitForResponse(1);
end


end