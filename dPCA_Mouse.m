function [] = dPCA_Mouse(overall_PCAmatrix, raw_data)

%% Extract the trials for dPCA and get corresponding variables
[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);
overall_PCAmatrix = reshape(overall_PCAmatrix, [trialNum, timespan, coordinate*labelNum]);
[trialNum, T, N] = size(overall_PCAmatrix);     % T number of timepoint;    N number of labels (*2 because x and y)

S = 2;          % number of stimuli
D = 2;          % number of decisions, not include no response
O = 2;          % opto/control
FO = 2;         % number of former outcomes, not include no response
FR = 2;         % number of former decisions, not include no response


find_maxTrialRepetitions = zeros(S,D,O,FO,FR);
for a = 2 : trialNum
    if raw_data.DistStim(a) == 0
        
        if ~isnan(raw_data.ResponseSide(a)) && ~isnan(raw_data.ResponseSide(a-1))
            if isnan(raw_data.optoType(a))
                opto_idx = 1;
            else
                opto_idx = 2;
            end
            
            resp_idx = raw_data.ResponseSide(a);
            former_out_idx = raw_data.Rewarded(a-1) + 1;
            former_resp_idx = raw_data.ResponseSide(a-1);
            
            find_maxTrialRepetitions(raw_data.CorrectSide(a), resp_idx, opto_idx, former_out_idx, former_resp_idx) = ...
                find_maxTrialRepetitions(raw_data.CorrectSide(a), resp_idx, opto_idx, former_out_idx, former_resp_idx) + 1;           
        end
        
    else
        fprintf(2, 'This datase contains Rate Discrimination trials!! \n');
        return;
    end
end

E = max(find_maxTrialRepetitions(:));         % maximal number of trial repetitions
clear a timespan coordinate labelNum opto_idx resp_idx former_resp_idx former_out_idx


%% Building the matrix for dPCA, "firingRates"
overall_PCAmatrix = reshape(overall_PCAmatrix, [trialNum, N, T]);
firingRates = NaN(N,S,D,O,FO,FR,T,E);
TrialRepetitions = ones(S,D,O,FO,FR);
for a = 2 : trialNum
    if ~isnan(raw_data.ResponseSide(a)) && ~isnan(raw_data.ResponseSide(a-1))
        if isnan(raw_data.optoType(a))
            opto_idx = 1;
        else
            opto_idx = 2;
        end
        
        resp_idx = raw_data.ResponseSide(a);
        former_out_idx = raw_data.Rewarded(a-1) + 1;
        former_resp_idx = raw_data.ResponseSide(a-1);
        
        idx = TrialRepetitions(raw_data.CorrectSide(a), resp_idx, opto_idx, former_out_idx, former_resp_idx);
        firingRates(:, raw_data.CorrectSide(a), resp_idx, opto_idx, former_out_idx, former_resp_idx, :, idx) = overall_PCAmatrix(a, :, :);
        
        TrialRepetitions(raw_data.CorrectSide(a), resp_idx, opto_idx, former_out_idx, former_resp_idx) = ...
            TrialRepetitions(raw_data.CorrectSide(a), resp_idx, opto_idx, former_out_idx, former_resp_idx) + 1;
        
   end
end

clear a opto_idx resp_idx former_resp_idx former_out_idx


%% Running dPCA-Preparing the parameters
firingRatesAverage = nanmean(firingRates, 8);

% (neurons), i.e. we have the following parameters:
%    1 - stimulus
%    2 - response side
%    3 - opto
%    4 - former outcome
%    5 - former response
%    6 - time

combinedParams = {{1, [1 6]}, {2, [2 6]}, {3, [3 6]}, {[1 2], [1 2 6]}, {4, [4 6]}, {5, [5 6]}, {6}};
margNames = {'Stimulus', 'ResponseSide', 'Opto', 'Reward', 'Reward n-1', 'ResponseSide n-1', 'Condition-independent'};
margColours = [0, 0.4470, 0.7410; 0.6350, 0.0780, 0.1840; 0.9290, 0.6940, 0.1250; 0.4940, 0.1840, 0.5560; 0.4660, 0.6740, 0.1880; 0.3010, 0.7450, 0.9330; 0.5, 0.5, 0.5];



time = 1:T;
timeEvents = [15, 45, 60];    % The markers of Baseline; Stimulus On; Delay; Spouts In


%% Running dPCA-Step 1: PCA of the dataset

X = firingRatesAverage(:,:);
X = bsxfun(@minus, X, mean(X,2));

[W,~,~] = svd(X, 'econ');
W = W(:,1:N);

% minimal plotting
dpca_plot(firingRatesAverage, W, W, @dpca_plot_default);

% computing explained variance
explVar = dpca_explainedVariance(firingRatesAverage, W, W, ...
    'combinedParams', combinedParams);

% a bit more informative plotting
dpca_plot(firingRatesAverage, W, W, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours);


%% Running dPCA-Step 2: PCA in each marginalization separately
MarginalName = ["Stimulus", "ResponseSide", "Opto", "Reward", "Reward n-1", "ResponseSide n-1", "Condition-independent"];

dpca_perMarginalization(firingRatesAverage, @dpca_plot_default, ...
    MarginalName, 'combinedParams', combinedParams);


%% Running dPCA-Step 3: dPCA without regularization and ignoring noise covariance

% This is the core function.
% W is the decoder, V is the encoder (ordered by explained variance),
% whichMarg is an array that tells you which component comes from which
% marginalization

tic
[W,V,whichMarg] = dpca(firingRatesAverage, N, ...
    'combinedParams', combinedParams);
toc

explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams);

dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16);


end